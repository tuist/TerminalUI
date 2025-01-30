import Foundation

public struct WarningAlert: ExpressibleByStringLiteral {
    let message: TerminalText
    let nextStep: TerminalText?

    public static func alert(_ message: TerminalText, nextStep: TerminalText? = nil) -> WarningAlert {
        WarningAlert(message, nextStep: nextStep)
    }

    init(_ message: TerminalText, nextStep: TerminalText? = nil) {
        self.message = message
        self.nextStep = nextStep
    }

    public init(stringLiteral value: String) {
        message = TerminalText(stringLiteral: value)
        nextStep = nil
    }
}

public struct SuccessAlert: ExpressibleByStringLiteral {
    let message: TerminalText
    let nextSteps: [TerminalText]

    public static func alert(_ message: TerminalText, nextSteps: [TerminalText] = []) -> SuccessAlert {
        SuccessAlert(message, nextSteps: nextSteps)
    }

    init(_ message: TerminalText, nextSteps: [TerminalText] = []) {
        self.message = message
        self.nextSteps = nextSteps
    }

    public init(stringLiteral value: String) {
        message = TerminalText(stringLiteral: value)
        nextSteps = []
    }
}

public struct ErrorAlert: ExpressibleByStringLiteral {
    let message: TerminalText
    let nextSteps: [TerminalText]

    public static func alert(_ message: TerminalText, nextSteps: [TerminalText] = []) -> ErrorAlert {
        ErrorAlert(message, nextSteps: nextSteps)
    }

    init(_ message: TerminalText, nextSteps: [TerminalText] = []) {
        self.message = message
        self.nextSteps = nextSteps
    }

    public init(stringLiteral value: String) {
        message = TerminalText(stringLiteral: value)
        nextSteps = []
    }
}

public protocol Noorable {
    func singleChoicePrompt<T: Equatable & CustomStringConvertible>(
        question: TerminalText,
        options: [T]
    ) -> T

    /// It shows multiple options to the user to select one.
    /// - Parameters:
    ///   - title: A title that captures what's being asked.
    ///   - question: The quetion to ask to the user.
    ///   - options: The options to show to the user.
    ///   - description: Use it to add some explanation to what the question is for.
    ///   - collapseOnSelection: Whether the prompt should collapse after the user selects an option.
    /// - Returns: The option selected by the user.
    func singleChoicePrompt<T: Equatable & CustomStringConvertible>(
        title: TerminalText?,
        question: TerminalText,
        options: [T],
        description: TerminalText?,
        collapseOnSelection: Bool
    ) -> T

    func singleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        question: TerminalText
    ) -> T

    /// It shows multiple options to the user to select one.
    /// - Parameters:
    ///   - title: A title that captures what's being asked.
    ///   - question: The quetion to ask to the user.
    ///   - description: Use it to add some explanation to what the question is for.
    ///   - collapseOnSelection: Whether the prompt should collapse after the user selects an option.
    /// - Returns: The option selected by the user.
    func singleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        title: TerminalText?,
        question: TerminalText,
        description: TerminalText?,
        collapseOnSelection: Bool
    ) -> T

    func yesOrNoChoicePrompt(
        title: TerminalText?,
        question: TerminalText
    ) -> Bool

    /// It shows a component to answer yes or no to a question.
    /// - Parameters:
    ///   - title: A title that captures what's being asked.
    ///   - question: The quetion to ask to the user.
    ///   - defaultAnswer: Whether the default selected answer is yes or no (true or false)
    ///   - description: An optional description to add additional context around what the question is for.
    ///   - collapseOnSelection: When true, the question is collapsed after the question is entered.
    /// - Returns: The option selected by the user.
    func yesOrNoChoicePrompt(
        title: TerminalText?,
        question: TerminalText,
        defaultAnswer: Bool,
        description: TerminalText?,
        collapseOnSelection: Bool
    ) -> Bool

    /// It shows a success alert.
    /// - Parameters:
    ///   - alert: The success message
    func success(_ alert: SuccessAlert)

    /// It shows an error alert.
    /// - Parameters:
    ///   - alert: The error message
    func error(_ alert: ErrorAlert)

    /// It shows a warning alert.
    /// - Parameters:
    ///   - alerts: The warning messages.
    func warning(_ alerts: WarningAlert...)

    /// Shows a progress step.
    /// - Parameters:
    ///   - message: The message that represents "what's being done"
    ///   - action: The asynchronous task to run. The caller can use the argument that the function takes to update the step
    /// message.
    func progressStep(
        message: String,
        action: @escaping ((String) -> Void) async throws -> Void
    ) async throws

    /// Shows a progress step.
    /// - Parameters:
    ///   - message: The message that represents "what's being done"
    ///   - successMessage: The message that the step gets updated to when the action completes.
    ///   - errorMessage: The message that the step gets updated to when the action errors.
    ///   - showSpinner: True to show a spinner.
    ///   - action: The asynchronous task to run. The caller can use the argument that the function takes to update the step
    /// message.
    func progressStep(
        message: String,
        successMessage: String?,
        errorMessage: String?,
        showSpinner: Bool,
        action: @escaping ((String) -> Void) async throws -> Void
    ) async throws
}

public struct Noora: Noorable {
    let theme: Theme
    let terminal: Terminaling

    public init(theme: Theme = .default, terminal: Terminaling = Terminal()) {
        self.theme = theme
        self.terminal = terminal
    }

    public func singleChoicePrompt<T>(question: TerminalText, options: [T]) -> T where T: CustomStringConvertible, T: Equatable {
        singleChoicePrompt(title: nil, question: question, options: options, description: nil, collapseOnSelection: true)
    }

    public func singleChoicePrompt<T>(
        title: TerminalText?,
        question: TerminalText,
        options: [T],
        description: TerminalText?,
        collapseOnSelection: Bool
    ) -> T where T: CustomStringConvertible, T: Equatable {
        let component = SingleChoicePrompt(
            title: title,
            question: question,
            description: description,
            theme: theme,
            terminal: terminal,
            collapseOnSelection: collapseOnSelection,
            renderer: Renderer(),
            standardPipelines: StandardPipelines(),
            keyStrokeListener: KeyStrokeListener()
        )
        return component.run(options: options)
    }

    public func singleChoicePrompt<T>(question: TerminalText) -> T where T: CaseIterable, T: CustomStringConvertible,
        T: Equatable
    {
        singleChoicePrompt(title: nil, question: question, description: nil, collapseOnSelection: true)
    }

    public func singleChoicePrompt<T: CaseIterable & CustomStringConvertible & Equatable>(
        title: TerminalText? = nil,
        question: TerminalText,
        description: TerminalText? = nil,
        collapseOnSelection: Bool = true
    ) -> T {
        let component = SingleChoicePrompt(
            title: title,
            question: question,
            description: description,
            theme: theme,
            terminal: terminal,
            collapseOnSelection: collapseOnSelection,
            renderer: Renderer(),
            standardPipelines: StandardPipelines(),
            keyStrokeListener: KeyStrokeListener()
        )
        return component.run()
    }

    public func yesOrNoChoicePrompt(title: TerminalText?, question: TerminalText) -> Bool {
        yesOrNoChoicePrompt(title: title, question: question, defaultAnswer: true, description: nil, collapseOnSelection: true)
    }

    public func yesOrNoChoicePrompt(
        title: TerminalText? = nil,
        question: TerminalText,
        defaultAnswer: Bool = true,
        description: TerminalText? = nil,
        collapseOnSelection: Bool
    ) -> Bool {
        YesOrNoChoicePrompt(
            title: title,
            question: question,
            description: description,
            theme: theme,
            terminal: terminal,
            collapseOnSelection: collapseOnSelection,
            renderer: Renderer(),
            standardPipelines: StandardPipelines(),
            keyStrokeListener: KeyStrokeListener(),
            defaultAnswer: defaultAnswer
        ).run()
    }

    public func success(_ alert: SuccessAlert) {
        Alert(
            item: .success(alert.message, nextSteps: alert.nextSteps),
            standardPipelines: StandardPipelines(),
            terminal: terminal,
            theme: theme
        ).run()
    }

    public func error(_ alert: ErrorAlert) {
        Alert(
            item: .error(alert.message, nextSteps: alert.nextSteps),
            standardPipelines: StandardPipelines(),
            terminal: terminal,
            theme: theme
        ).run()
    }

    public func warning(_ alerts: WarningAlert...) {
        Alert(
            item: .warning(alerts.map { (message: $0.message, nextStep: $0.nextStep) }),
            standardPipelines: StandardPipelines(),
            terminal: terminal,
            theme: theme
        ).run()
    }

    public func progressStep(message: String, action: @escaping ((String) -> Void) async throws -> Void) async throws {
        try await progressStep(message: message, successMessage: nil, errorMessage: nil, showSpinner: true, action: action)
    }

    public func progressStep(
        message: String,
        successMessage: String? = nil,
        errorMessage: String? = nil,
        showSpinner: Bool = true,
        action: @escaping ((String) -> Void) async throws -> Void
    ) async throws {
        let progressStep = ProgressStep(
            message: message,
            successMessage: successMessage,
            errorMessage: errorMessage,
            showSpinner: showSpinner,
            action: action,
            theme: theme,
            terminal: terminal,
            renderer: Renderer(),
            standardPipelines: StandardPipelines()
        )
        try await progressStep.run()
    }
}
