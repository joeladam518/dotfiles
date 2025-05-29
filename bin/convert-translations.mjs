#!/usr/bin/env node
import fs from 'node:fs';
import { basename, join } from 'node:path';

/**
 * @param {boolean} error
 * @returns {void}
 */
function printUsage(error = false) {
    const args = process.argv.slice(basename(process.argv[0]) === 'node' ? 1 : 0);
    const scriptName = basename(args[0]);
    const usage = `Usage: node ${scriptName} ` +
        '<file|directory> ' +
        '[-h|--help] ' +
        '[-l|--language <file|directory>] ' +
        '[-n|--only-needed] ' +
        '[-o|--output <directory>]';

    if (error) {
        console.error(usage)
    } else {
        console.log(usage);
    }
}

function printHelp() {
    printUsage();
    const help = `
Converts a translation files from json to csv and back again.

Arguments:
<file|directory>                 The file or directory to convert.

Options:
-h, --help                       Show this help message and exit.
-l, --language <file|directory>  Use a reference file to filter translations.
-n, --only-needed                Only include translations that differ from the reference.
-o, --output <directory>         Write the output to a specific directory.
    `;

    console.log(help);
}

/**
 * @returns {{argPath: string, refPath: string|null, onlyNeeded: boolean, outputDir: string|null}}
 */
function parseArguments() {
    const args = process.argv.slice(basename(process.argv[0]) === 'node' ? 2 : 1);
    if (args.length < 1) {
        printUsage(true);
        process.exit(1);
    }
    let argPath = null;
    let refPath = null;
    let onlyNeeded = false;
    let outputDir = null;
    for (let i = 0; i < args.length; ++i) {
        if (args[i] === '-h' || args[i] === '--help') {
            printHelp();
            process.exit(0);
        } else if (args[i].startsWith('--language=')) {
            refPath = args[i].split('=')[1];
        } else if (args[i] === '-l' || args[i] === '--language') {
            if (i + 1 >= args.length) {
                printUsage();
                process.exit(1);
            }
            refPath = args[i + 1];
            i++;
        } else if (args[i].startsWith('--output=')) {
            outputDir = args[i].split('=')[1];
        } else if (args[i] === '-o' || args[i] === '--output') {
            if (i + 1 >= args.length) {
                printUsage(true);
                process.exit(1);
            }
            outputDir = args[i + 1];
            i++;
        } else if (args[i] === '-n' || args[i] === '--only-needed') {
            onlyNeeded = true;
        } else {
            if (!argPath) {
                argPath = args[i];
            } else {
                console.error('Invalid argument:', args[i], '\n');
                printUsage(true);
                process.exit(1);
            }
        }
    }
    return { argPath, refPath, onlyNeeded, outputDir };
}

// --- Helpers ---

/**
 * @param {string} file
 * @returns {boolean}
 */
function isJsonFile(file) {
    return file.endsWith('.json');
}

/**
 * @param {string} file
 * @returns {boolean}
 */
function isCsvFile(file) {
    return file.endsWith('.csv');
}

/**
 * @param {string} path
 * @returns {boolean}
 */
function isDir(path) {
    try {
        return fs.statSync(path).isDirectory();
    } catch {
        return false;
    }
}

/**
 * @param {string} path
 * @returns {boolean}
 */
function isFile(path) {
    try {
        return fs.statSync(path).isFile();
    } catch {
        return false;
    }
}

/**
 * @param {string} directory
 * @returns {string[]}
 */
function listFiles(directory) {
    return fs.readdirSync(directory).filter(f => isFile(join(directory, f)));
}

// --- JSON <-> CSV flatten/unflatten ---

/**
 * @param {any} obj
 * @param {string} prefix
 * @param {Record<string, any>} output
 * @returns {Record<string, any>}
 */
function flatten(obj, prefix = '', output = {}) {
    if (Array.isArray(obj)) {
        obj.forEach((value, index) => flatten(value, prefix ? `${prefix}.${index}` : `${index}`, output));
    } else if (obj && typeof obj === 'object') {
        for (const key in obj) {
            flatten(obj[key], prefix ? `${prefix}.${key}` : key, output);
        }
    } else {
        output[prefix] = obj;
    }
    return output;
}

/**
 * @param {Record<string, any>} flatObj
 * @returns {Record<string, any>}
 */
function unflatten(flatObj) {
    const result = {};
    for (const key in flatObj) {
        const parts = key.split('.');
        let current = result;
        for (let i = 0; i < parts.length; ++i) {
            const part = parts[i];
            const isLast = i === parts.length - 1;
            const nextPart = parts[i + 1];
            const isArrayIdx = !isNaN(Number(nextPart));
            if (isLast) {
                current[part] = flatObj[key];
            } else {
                if (!(part in current)) {
                    current[part] = isArrayIdx ? [] : {};
                }
                current = current[part];
            }
        }
    }
    return result;
}

// --- CSV Parsing/Serializing ---

/**
 * @param {string} content
 * @returns {Record<string, any>[]}
 */
function parseCsv(content) {
    const lines = content.split(/\r?\n/).filter(Boolean);
    if (!lines.length) return [];
    const [header, ...rows] = lines;
    const columns = header.split(',');
    if (columns.length < 3) throw new Error('CSV must have at least 3 columns');
    return rows.map(line => {
        const firstComma = line.indexOf(',');
        const secondComma = line.indexOf(',', firstComma + 1);
        return {
            key: line.slice(0, firstComma),
            english: line.slice(firstComma + 1, secondComma),
            value: line.slice(secondComma + 1)
        };
    });
}

/**
 * @param {Record<string, any>[]} rows
 * @returns {string}
 */
function serializeCsv(rows) {
    let output = 'key,english value,value\n';
    for (const row of rows) {
        const escapeCsv = value => value == null ? '' : String(value).replace(/"/g, '""').replace(/,/g, '');
        output += `${escapeCsv(row.key)},${escapeCsv(row.english)},${escapeCsv(row.value)}\n`;
    }
    return output;
}

// --- Reference Filtering ---

/**
 * Helper to determine if a key should be included based on filtering requirements
 *
 * @param {string} key
 * @param {Record<string, any>} flatArg
 * @param {Record<string, any>} flatRef
 * @returns {boolean}
 */
function shouldIncludeKey(key, flatArg, flatRef) {
    if (!(key in flatRef)) {
        return true;
    }

    const argValue = flatArg[key];
    const refValue = flatRef[key];
    if (refValue === '') {
        return true;
    }

    if (refValue === argValue) {
        return true;
    }

    return false;
}

/**
 * @param {Record<string, any>} flatArg
 * @param {Record<string, any>} flatRef
 * @returns {Record<string, any>}
 */
function filterWithReference(flatArg, flatRef) {
    const result = {};
    for (const key in flatArg) {
        if (shouldIncludeKey(key, flatArg, flatRef)) {
            result[key] = flatArg[key];
        }
    }
    return result;
}

// --- Main Logic ---

/**
 * @param {string} jsonPath
 * @param {string} refPath
 * @param {boolean} onlyNeeded
 * @param {string|null} outputDir
 * @returns {void}
 */
function processJsonToCsv(jsonPath, refPath, onlyNeeded, outputDir = null) {
    const raw = fs.readFileSync(jsonPath, 'utf8');
    let data;
    try {
        data = JSON.parse(raw);
    } catch (e) {
        throw new Error(`Invalid JSON in ${jsonPath}`);
    }
    const flat = flatten(data);
    let filtered = flat;
    let refFlat = null;
    if (refPath) {
        const refRaw = fs.readFileSync(refPath, 'utf8');
        let refData;
        try {
            refData = JSON.parse(refRaw);
        } catch (e) {
            throw new Error(`Invalid JSON in reference file ${refPath}`);
        }
        refFlat = flatten(refData);
        if (onlyNeeded) {
            filtered = filterWithReference(flat, refFlat);
        }
    }
    const rows = Object.keys(filtered).map(key => ({
        key,
        english: filtered[key],
        value: (refFlat && key in refFlat && refFlat[key] !== filtered[key]) ? refFlat[key] : ''
    }));
    if (onlyNeeded && rows.length === 0) {
        console.log(`Skipped ${jsonPath}: no needed translations.`);
        return;
    }
    const csv = serializeCsv(rows);
    const baseName = jsonPath.replace(/^.*[\/]/, '').replace(/\.json$/i, '');
    const outPath = outputDir
        ? join(outputDir, `${baseName}.csv`)
        : join(process.cwd(), `${baseName}.csv`);
    fs.writeFileSync(outPath, csv, 'utf8');
    console.log(`Wrote ${outPath}`);
}

/**
 * @param {string} csvPath
 * @param {string|null} outputDir
 * @returns {void}
 */
function processCsvToJson(csvPath, outputDir = null) {
    const raw = fs.readFileSync(csvPath, 'utf8');
    const rows = parseCsv(raw);
    const flat = {};
    for (const row of rows) {
        flat[row.key] = row.value !== '' ? row.value : row.english;
    }
    const data = unflatten(flat);
    const baseName = csvPath.replace(/^.*[\/]/, '').replace(/\.csv$/i, '');
    const outPath = outputDir
        ? join(outputDir, `${baseName}.json`)
        : join(process.cwd(), `${baseName}.json`);
    fs.writeFileSync(outPath, JSON.stringify(data, null, 2), 'utf8');
    console.log(`Wrote ${outPath}`);
}

// --- Directory Handling ---

/**
 * @param {string} dirPath
 * @param {string} refDirPath
 * @param {boolean} onlyNeeded
 * @param {string|null} userOutputDir
 * @returns {void}
 */
function processDirectory(dirPath, refDirPath, onlyNeeded, userOutputDir = null) {
    const files = listFiles(dirPath);
    if (!files.length) {
        throw new Error(`No files in directory: ${dirPath}`);
    }
    const allJson = files.every(isJsonFile);
    const allCsv = files.every(isCsvFile);
    if (!allJson && !allCsv) throw new Error('Directory must contain only .json or only .csv files');
    // Create output directory in current working directory or use user provided
    let baseDirName = dirPath.replace(/^.*[\/]/, '');
    let outputDir = userOutputDir
        ? join(process.cwd(), userOutputDir)
        : join(process.cwd(), baseDirName);
    // If the input directory is in the current working directory and no user output, add 'processed_' prefix to avoid conflict
    if (!userOutputDir && fs.realpathSync(dirPath) === outputDir) {
        baseDirName = `processed_${baseDirName}`;
        outputDir = join(process.cwd(), baseDirName);
    }
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
    }
    if (allJson) {
        let refFiles = null;
        if (refDirPath) {
            refFiles = listFiles(refDirPath);
            if (refFiles.length !== files.length) {
                throw new Error('Reference directory must have same number of files as argument directory');
            }
            if (refFiles.some(f => !isJsonFile(f))) {
                throw new Error('Reference directory must contain only .json files');
            }
        }
        for (const [index, file] of files.entries()) {
            const refFile = refDirPath ? join(refDirPath, refFiles[index]) : null;
            processJsonToCsv(join(dirPath, file), refFile, onlyNeeded, outputDir);
        }
    } else if (allCsv) {
        for (const file of files) {
            processCsvToJson(join(dirPath, file), outputDir);
        }
    } else {
        throw new Error('Directory must contain only .json or only .csv files');
    }
}

/**
 * @returns {void}
 */
function main() {
    const { argPath, refPath, onlyNeeded, outputDir } = parseArguments();
    try {
        if (!argPath) {
            throw new Error('Argument path is required');
        }
        if (!fs.existsSync(argPath)) {
            throw new Error(`Path does not exist: ${argPath}`);
        }
        if (isFile(argPath)) {
            if (isJsonFile(argPath)) {
                if (refPath && (!isFile(refPath) || !isJsonFile(refPath))) {
                    throw new Error('Reference path must be a file when argument is a file');
                }
                processJsonToCsv(argPath, refPath, onlyNeeded, outputDir);
            } else if (isCsvFile(argPath)) {
                processCsvToJson(argPath, outputDir);
            } else {
                throw new Error('File must be .json or .csv');
            }
        } else if (isDir(argPath)) {
            if (refPath && !isDir(refPath)) {
                throw new Error('Reference path must be a directory when argument is a directory');
            }
            processDirectory(argPath, refPath, onlyNeeded, outputDir);
        } else {
            throw new Error('Argument must be a file or directory');
        }
    } catch (e) {
        console.error('Error:', e.message);
        process.exit(1);
    }
}

main();
