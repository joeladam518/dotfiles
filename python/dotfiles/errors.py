class EmptyAnswerError(ValueError):
    pass


class InvalidAnswerError(ValueError):
    pass


class InvalidCommand(ValueError):
    """Represents an invalid command"""
    def __init__(self, command: str):
        super().__init__(f'Invalid command "{command}"')
        self.command = command


class InvalidSubcommand(ValueError):
    """Represents an invalid command"""
    def __init__(self, command: str, subcommand: str):
        super().__init__(f'the following arguments are required: subcommand')
        self.command = command
        self.subcommand = subcommand


class ValidationError(ValueError):
    """Represents a validation error"""
    def __init__(self, command: str, message: str):
        super().__init__(message)
        self.command = command
