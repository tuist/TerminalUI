#if DEBUG
    import Rainbow

    public struct NooraMock: Noorable,
        CustomStringConvertible
    {
        private let noora: Noorable
        var standardPipelineEventsRecorder = StandardPipelineEventsRecorder()

        public var description: String {
            standardPipelineEventsRecorder.events.map { event in
                event.content.split(separator: "\n")
                    .map {
                        "\(event.type): \($0)"
                    }.joined(separator: "\n")
            }.joined(separator: "\n")
        }

        public init(theme: Theme = .default, terminal: Terminaling = Terminal()) {
            noora = Noora(theme: theme, terminal: terminal, standardPipelines: StandardPipelines(
                output: StandardPipeline(type: .output, eventsRecorder: standardPipelineEventsRecorder),
                error: StandardPipeline(type: .error, eventsRecorder: standardPipelineEventsRecorder)
            ))
        }

        public class StandardPipelineEventsRecorder {
            var events: [StandardOutputEvent] = []
        }

        public struct StandardOutputEvent: Equatable {
            let type: StandardPipelineType
            let content: String
        }

        public enum StandardPipelineType: CustomStringConvertible {
            public var description: String {
                switch self {
                case .error: "stderr"
                case .output: "stdout"
                }
            }

            case output
            case error
        }

        public struct StandardPipeline: StandardPipelining {
            let type: StandardPipelineType
            let eventsRecorder: StandardPipelineEventsRecorder

            public func write(content: String) {
                eventsRecorder.events.append(.init(type: type, content: content.removingAllStyles()))
            }
        }

        public func singleChoicePrompt<T>(question: TerminalText) -> T where T: CaseIterable, T: CustomStringConvertible,
            T: Equatable
        {
            noora.singleChoicePrompt(question: question)
        }

        public func singleChoicePrompt<T>(
            title: TerminalText?,
            question: TerminalText,
            description: TerminalText?,
            collapseOnSelection: Bool
        ) -> T where T: CaseIterable, T: CustomStringConvertible, T: Equatable {
            noora.singleChoicePrompt(
                title: title,
                question: question,
                description: description,
                collapseOnSelection: collapseOnSelection
            )
        }

        public func yesOrNoChoicePrompt(title: TerminalText?, question: TerminalText) -> Bool {
            noora.yesOrNoChoicePrompt(title: title, question: question)
        }

        public func yesOrNoChoicePrompt(
            title: TerminalText?,
            question: TerminalText,
            defaultAnswer: Bool,
            description: TerminalText?,
            collapseOnSelection: Bool
        ) -> Bool {
            noora.yesOrNoChoicePrompt(
                title: title,
                question: question,
                defaultAnswer: defaultAnswer,
                description: description,
                collapseOnSelection: collapseOnSelection
            )
        }

        public func success(_ alert: SuccessAlert) {
            noora.success(alert)
        }

        public func error(_ alert: ErrorAlert) {
            noora.error(alert)
        }

        public func warning(_ alerts: WarningAlert...) {
            warning(alerts)
        }

        public func warning(_ alerts: [WarningAlert]) {
            noora.warning(alerts)
        }

        public func progressStep(message: String, action: @escaping ((String) -> Void) async throws -> Void) async throws {
            try await noora.progressStep(message: message, action: action)
        }

        public func progressStep(
            message: String,
            successMessage: String?,
            errorMessage: String?,
            showSpinner: Bool,
            action: @escaping ((String) -> Void) async throws -> Void
        ) async throws {
            try await noora.progressStep(
                message: message,
                successMessage: successMessage,
                errorMessage: errorMessage,
                showSpinner: showSpinner,
                action: action
            )
        }
    }
#endif
