class EmptyAnswerError(ValueError):
    pass


class InvalidAnswerError(ValueError):
    pass


class ValidationError(ValueError):
    """Represents a validation error"""
    def __init__(self, command: str, message: str):
        super().__init__(message)
        self.command = command
