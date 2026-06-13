#import "@preview/touying:0.7.4": *
#import "themes/theme.typ": *
#import "@preview/fontawesome:0.6.1": *
#import "@preview/ctheorems:1.1.3": *
#import "@preview/numbly:0.1.0": numbly
#import "utils.typ": *

// Pdfpc configuration
// typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc
#let pdfpc-config = pdfpc.config(
    duration-minutes: 30,
    start-time: datetime(hour: 14, minute: 10, second: 0),
    end-time: datetime(hour: 14, minute: 40, second: 0),
    last-minutes: 5,
    note-font-size: 12,
    disable-markdown: false,
    default-transition: (
      type: "push",
      duration-seconds: 2,
      angle: ltr,
      alignment: "vertical",
      direction: "inward",
    ),
  )

// Theorems configuration by ctheorems
#show: thmrules.with(qed-symbol: $square$)
#let theorem = thmbox("theorem", "Theorem", fill: rgb("#eeffee"))
#let corollary = thmplain(
  "corollary",
  "Corollary",
  base: "theorem",
  titlefmt: strong
)
#let definition = thmbox("definition", "Definition", inset: (x: 1.2em, top: 1em))
#let example = thmplain("example", "Example").with(numbering: none)
#let proof = thmproof("proof", "Proof")

#show: theme.with(
  aspect-ratio: "4-3",
  footer: self => self.info.author + ", " + self.info.institution + " - " + self.info.date,
  config-common(
    // handout: true,
    preamble: pdfpc-config, 
  ),
  config-info(
    title: [AI-Engineering: Tools, Agents and Verification],
    //subtitle: [Vibe Coding, AI-Assisted Development, and Levels of Autonomy],
    author: [Gianluca Aguzzi],
    date: datetime.today().display("[day] [month repr:long] [year]"),
    institution: [Università di Bologna],
    // logo: emoji.school,
  ),
)

#set text(font: "Roboto", weight: "regular", size: 20pt)
#show math.equation: set text(font: "Fira Math")
#show strong: set text(fill: rgb("#005587"))
#show emph: set text(style: "italic", fill: rgb("#00a3e0"))
#set underline(stroke: 1.5pt + rgb("#005587"), offset: 2pt)
#let highlight(body, fill: rgb("#fff1a8")) = box(
  fill: fill,
  inset: (x: 0.14em, y: 0.06em),
  radius: 0.12em,
)[#body]
#let definition-line(body) = block(
  width: 100%,
  inset: (x: 0.85em, y: 0.68em),
  fill: rgb("#fbfdff"),
  radius: 8pt,
  stroke: (paint: rgb("#cfd9e0"), thickness: 0.9pt),
)[
  #emph[#text(size: 1.02em, fill: rgb("#23373b"))[#body]]
]
#let kicker(body) = text(size: 0.72em, fill: rgb("#8fd3ff"))[#body]
// Keyline highlights: use to draw attention to central ideas.
// - keyline: (Yellow) Core takeaways, critical definitions, and central concepts.
// - keyline-blue: (Blue) Technical frameworks, architectural concepts, and system definitions.
// - keyline-green: (Green) Practical tips, successful patterns, and actionable steps.
#let keyline(body, fill: rgb("#fff1a8")) = highlight(fill: fill)[#text(size: 0.96em, fill: rgb("#23373b"))[#body]]
#let keyline-blue(body) = keyline(body, fill: rgb("#d9e8f5"))
#let keyline-green(body) = keyline(body, fill: rgb("#e2f0d9"))
#let divider(label, title, subtitle: none) = focus-slide(align: left + horizon)[
  #kicker(label)
  #v(0.55em)
  #text(size: 1.34em, weight: "medium")[#title]
  #if subtitle != none {
    v(0.75em)
    text(size: 0.78em, fill: rgb("#d7e6ef"))[#subtitle]
  }
]
#show raw.where(block: true): it => block(
  width: 100%,
  fill: rgb("#f7fafc"),
  inset: (x: 0.9em, y: 0.8em),
  radius: 8pt,
  stroke: (paint: rgb("#d6e0e7"), thickness: 0.8pt),
)[
  #set text(size: 0.82em)
  #it
]
#show quote.where(block: true): it => block(
  fill: rgb("#f4f8fa"),
  inset: 1em,
  radius: 0.2em,
  stroke: (left: 4pt + rgb("#005587")),
  text(style: "italic", it)
)

#title-slide()

== Today's Lesson: Agentic AI with LLMs

- *Guiding question*: how can a language model _perceive_, _decide_, _act_, _remember_, and remain _verifiable_?
- #underline[What you should leave with]
  - A precise definition of *agentic AI* and its core properties
  - A system view of how *tools* turn language into action
  - A conceptual distinction between *short-term*, and *long-term* memory
  - A verification mindset for evaluating multi-step behavior
- *Roadmap:* agents, LangChain4j, tools, memory, verification

#divider(
  [Part I · Foundations],
  [Agent Loops and System Properties],
  subtitle: [Perception, action, objectives, and temporality define the system],
)

== Why Study Agentic AI Now?

- #keyline[Historical motivation:] modern agentic AI emerges when classical agent (like _reinforcement learning_) theory meets foundation-model capabilities
#v(0.25em)
- *Classical AI* already gave us the vocabulary of agents, environments, actions, and goals
  - Previous lessons on reinforcement learning and Markov decision processes introduced these concepts in a formal way :)
- *Modern LLMs* add a #keyline[practical] interface: they can interpret natural-language tasks and coordinate multi-step workflows
#v(0.25em)
- *This creates three engineering questions:*
  - how can an LLM become the _reasoning core_ of an agent?
    - Thinking model, planner, etc
  - how can that agent interact with external systems?
  - how can we verify whether the resulting behavior is correct, safe, and reliable?
- *Reference lens:* we will use _LangChain4j_ to discuss these ideas at the application level

== Agent: A Working Definition

#definition-line[
  An *agent* is a system that _perceives_ an environment, selects _actions_, and executes them in pursuit of explicit _objectives_
]
#v(0.35em)
- _Perception_ provides information about the current state of the world (or of the task)
- _Action_ modifies the environment, the system state, or the available knowledge
- _Objectives_ define the criterion by which one action is preferred over another
  #text(size: 0.9em)[
    - In LLM-based agents, objectives are often expressed as #keyline-green[natural-language instructions]
  ]
  
#v(0.25em)
- #underline[Key point:] agency is defined by the full #keyline-blue[perception-action loop], not by intelligence alone

#align(center)[
  #image("figures/reasoning-cycle.png", width: 50%)
]
== Core Properties of Agents

- #keyline[These properties tell us what kind of system we are building]
#v(0.25em)
- _Situatedness:_ the agent is #underline[embedded] in an environment and can #keyline[affect] it
- _Autonomy:_ the agent can choose actions without step-by-step human control
  - *Note:* autonomy is a spectrum, not a binary property
- _Goal-directedness:_ behavior is evaluated relative to explicit objectives
- _Temporality:_ decisions unfold over time rather than in a single isolated step
#v(0.25em)


#align(center)[
  #image("figures/single-turn-interaction.png", width: 50%)
]

== Building Blocks of an Agentic AI System

An agentic system works only when model, tools, memory, and orchestration remain #underline[aligned]
- _Reasoning layer_ - #underline[LLM]: interprets the goal, plans candidate actions, and synthesizes answers
- _Action layer_ - #underline[Tools]: expose external capabilities such as search, APIs, databases, or code execution
- _Continuity layer_ - #underline[Memory]: preserves information across steps and across interactions
- _Control layer_ - #underline[Orchestration]: translates model outputs into executable operations and returns observations

#align(center)[
  #image("figures/agent-revised.png", width: 45%)
]


== LangChain4j: AI Services

- #keyline-blue[AI Services are the first high-level abstraction above raw chat interactions]
#v(0.25em)
#definition-line[
  An _AI Service_ is a declarative Java interface whose methods are implemented by an LLM-backed runtime
]
- It sits above lower-level primitives such as `ChatModel` and explicit message orchestration.
- The application invokes a method, while the framework handles prompt construction, model invocation, and result mapping
- Optional capabilities such as #underline[tools], #underline[memory], and #underline[retrieval] can be attached to the same abstraction

== LangChain4j - Example AI Service

```scala
// Define a service interface with a user message template
trait SentimentAnalyzer:
  // The `@UserMessage` annotation specifies the prompt template for this method.
  @UserMessage(Array("Does {{it}} has a positive sentiment?"))
  def analyzeSentiment(text: String): Boolean

// A Factory method to create an instance of the service with a specific LLM model
object SentimentAnalyzer:
  def createWith(llmModel: ChatModel): SentimentAnalyzer =
    AiServices.builder(classOf[SentimentAnalyzer])
      .chatModel(llmModel)
      .build()

def testSentimentAnalyzer(): Unit =
  val model = OllamaChatModel.builder().baseUrl("http://localhost:11434")
    .modelName("gemma4:e2b")
    .build()
  val sentimentAnalyzer = SentimentAnalyzer.createWith(model)
  // Invoke the method, which internally constructs the prompt, calls the model, and returns the result.
  sentimentAnalyzer.analyzeSentiment("Scala is a great programming language!") // true
```
 
#divider(
  [Part II · Tools],
  [Tools turn language into action.],
  subtitle: [Interfaces, contracts, execution, and structured function calls.],
)

== Tools: What Is a Tool?

#definition-line[
  A *tool* is a #keyline-green[callable] resource outside the model, exposed through a well-defined interface
]
- A tool is not stored #keyline[inside] the model parameters
  - it is made available by the #keyline-green[surrounding] software system
#v(0.25em)
- *Minimum contract:*
  - _name_ for identification
    - e.g., "WebSearch", "Calculator", "SQLQuery", "CodeExecutor", "SensorReader"
  - _description_ for semantic guidance 
    - e.g., "use this to find recent information on the web"
  - _input schema_ for valid arguments,
    - e.g., a JSON schema that specifies required fields and types, with a clear format for the model to follow
  - _output schema_ for interpretable results
    - same as input schema, but for the tool's response
- *Examples:* web search, calculators, SQL queries, code execution, and sensor access.



== Why Are Tools Important?

- #keyline-green[Tools improve both epistemic quality and operational reach]
- *Grounding:* tools can reduce hallucination by connecting answers to external information sources
  - Before replying, the model can check facts, compute results, or query databases instead of relying solely on internal knowledge (#underline[self-augmentation] and #underline[self-correction] patterns)
- *Capability extension:* tools enable actions that plain text generation cannot perform #underline[reliably] on its own
  - e.g., performing calculations, or manipulating structured data
- *System interaction:* tools let the agent read from and write to *real* systems
- *Observability:* tool schemas make #underline[behavior] easier to inspect and evaluate
#v(0.25em)


== A Tool Is a Contract

- #keyline-green[Tool quality depends partly on prompt design and partly on interface design.]
#v(0.25em)
- A good tool specification acts as a contract between the #underline[model] and the #underline[execution] layer.
- *Name:* tells the model which capability #underline[exists]
- *Description:* tells the model when the capability should be used
- *Input schema:* constrains what arguments are acceptable
- *Output schema:* constrains what observations come back
#v(0.25em)
- #underline[Important:] better tool contracts usually produce more reliable tool selection and safer execution


== Tool Example: LangChain4j's Calculator
```scala
class Calculator:
  @Tool(name = "sum", value = Array("Calculate the sum of two numbers"))
  def sum(@P("left value")a: Double, b: Double): Double = a + b
  @Tool(name = "subtract", value = Array("Calculate the difference of two numbers"))
  def subtract(a: Double, b: Double): Double = a - b
  @Tool(name = "multiply", value = Array("Calculate the product of two numbers"))
  def multiply(a: Double, b: Double): Double = a * b
  @Tool(name = "divide", value = Array("Calculate the quotient of two numbers"))
  def divide(a: Double, b: Double): Double = a / b
```

- This simple calculator exposes four operations as callable tools
- The `@Tool` annotation prepare the method for invocation by the model, including schema generation and execution handling
- An `AIService` can include this `Calculator` as a #keyline-blue[capability]:
```scala
trait MathAgent:
  @UserMessage(Array("I need to perform this calculation: {{expression}}"))
  def calculate(expression: String): Double
@main def testMathAgent(): Unit =
  val model = //...
  val mathAgent = AiServices.builder(classOf[MathAgent]).chatModel(model)
.addTool(new Calculator).build()
  mathAgent.calculate("What is the sum of 5 and 7?") // 12.0
```

== Tool Description in LangChain4j
- #keyline-blue[Annotations are used to generate the tool's JSON schema.]
- The `@Tool` annotation provides the name and purpose.
- `@P` (or `@Parameter`) annotations describe the arguments.
- The framework then generates a structured schema for the LLM:
```scala
@Tool(value = Array("Tool description"))
  def tool(@P("first parameter") x: Any, @P("second parameter") y: Any): String =
```
- This is what the model sees as the tool specification:
```json
"tools": [{
  "type": "function",
  "function": {
    "name": "tool", "description": "Tool description",
    "parameters": {
      "type": "object", "properties": {
        "x": { "type": "object", "description": "first parameter" },
        "y": { "type": "object", "description": "second parameter" }
      },
      "required": ["x", "y"]
    }
  }
}]
```



== From Text Generation to Action
- How does the model's language output become an actual operation in the world?
- #keyline-blue[The orchestration layer converts #underline[language] into execution and execution back into #underline[context]]
#v(0.25em)
- A agentic system needs a #underline[software layer] that can:
  - describe #underline[available tools] to the model,
  - #underline[interpret] the model's action request,
  - #underline[execute] the selected tool,
  - return the result as a new observation.

#align(center)[
  #image("figures/react.png", width: 50%)
]

== Modern Tool Use: Zero-Shot to Native ReAct

- #keyline-blue[Core loop:] task ➡️ action request ➡️ execution ➡️ observation ➡️ continuation.
#v(0.25em)
- *Historical baseline:* zero-shot tool use described tools directly in the prompt and asked the model to emit a textual pseudo-command.
  - The prompt had to specify tool names, descriptions, call format, and the user task.
  - #highlight[Limitation:] formatting errors became execution errors.
#v(0.25em)
- *Current practice:* many modern models already support this #underline[ReAct-style loop] natively.
  - They decide when a tool is needed, emit a structured request, observe the result, and continue reasoning.
- *Function calling* is the usual interface: the model returns a typed function name with validated arguments instead of fragile free text.
- Frameworks such as _LangChain4j_ help normalize provider-specific tool-calling APIs at the application level.

== Tool Example - User, LLM and Tools Interaction


#image("figures/tool-llm-sequence.png", width: 100%)

== Tool Example - Multiple Tools at once
#image("figures/tool-chaining.png", width: 100%)

== Model Context Protocol (MCP)

- #keyline[The Problem:] traditional integrations (files, Slack, GitHub) require custom point-to-point glue code, leading to fragmentation and duplicate effort.
- #keyline[The Solution:] a standardized open protocol to securely connect AI models to any data source or tool.
  - _Build once, use everywhere:_ any compliant client can connect to any compliant tool server.
#v(0.25em)
- #highlight[Client-Server Architecture:]
  - *MCP Client:* your AI application (e.g., LangChain4j) requesting tool execution.
  - *MCP Server:* standalone process exposing dynamic schemas (e.g., `read_file`, `write_file`).
- *Discovery & Transports:* client discovers tools dynamically at startup via a handshake; communicates via local processes (_Stdio_) or remote hosts (_Streamable HTTP_).
#v(0.25em)
- _In LangChain4j:_ integrate `langchain4j-mcp` to connect with a rich ecosystem of community servers.
- We will not cover MCP, but conceptually it just a simple way to decouple the model's tool-calling interface from the actual implementation of tools.
#divider(
  [Part III · Memory],
  [Memory turns interaction into continuity.],
  subtitle: [Conversation state, working state, retrieval, and context injection.],
)

== Memory in Agentic AI Systems

#v(0.25em)
#definition-line[
  _Memory_ is the mechanism by which an agent #underline[stores], #underline[retrieves], and #underline[reuses]
   information across reasoning steps or across interactions.
]

- _History vs. Memory_ (Memory $!=$ History):
  - #underline[History:] a raw, passive, chronological transcript of what happened.
  - #underline[Memory:] an active, curated subset injected into the context to shape the reasoning process.

- _The four core pillars of memory:_
  - #underline[Continuity:] maintaining conversation context across turns and steps.
  - #underline[Personalization:] remembering user preferences, instructions, and settings.
  - #underline[Planning:] tracking current task state, subgoals, and execution progress.
  - #underline[Retrieval:] contextually injecting relevant prior or external knowledge.
  
== Types of Memory: Short vs. Long-Term

- #keyline[Memory is not monolithic; it serves different purposes and has different lifecycles.]
#v(0.25em)

- _Short-Term Memory_ (Working / Conversation State):
  - #underline[Scope:] limited to the current #underline[conversation] or active task.
  - #underline[Mechanism:] injected directly into the model's context window.
  - #underline[Purpose:] maintains immediate execution state, goals, and recent turns.
  - #underline[Lifecycle:] volatile; discarded or archived when the session ends.

- _Long-Term Memory_ (Persistent Knowledge):
  - #underline[Scope:] extends across multiple conversations and user interactions.
  - #underline[Mechanism:] stored in external databases/vector stores and retrieved dynamically.
  - #underline[Purpose:] remembers user preferences, historical patterns, and system instructions.
  - #underline[Lifecycle:] durable; persists indefinitely and is continuously updated.

== Short-Term Memory - LangChain4j Examples

- #keyline-blue[The primary abstraction for managing short-term context is `ChatMemory`.]
#v(0.25em)
- _Memory Policies:_ You can customize `ChatMemory` in several ways to fit context limits:
  - #underline[Eviction:] selectively dropping specific message types (e.g., redundant tool outputs).
  - #underline[Compression:] summarizing older turns to preserve context while saving tokens.
  - #underline[Filtering:] removing irrelevant or outdated intermediate reasoning steps.

```scala
// Configure a sliding window of the last 10 messages
val chatMemory: ChatMemory = MessageWindowChatMemory.withMaxMessages(10);
```

- _Multi-User Isolation via `@MemoryId`:_
  - For concurrent users, memory must be isolated per session.
  - LangChain4j routes user interactions dynamically to their respective `ChatMemory`:

```scala
trait Assistant {
  def chat(@MemoryId UUID sessionId, @UserMessage message: String): String
}
val assistant = AiServices.builder(Assistant.class)
  .chatModel(model)
  .chatMemoryProvider(sessionId -> MessageWindowChatMemory.withMaxMessages(10))
  .build();
```


== Long-Term Memory: Knowledge Base

- #keyline[Long-term memory is valuable only if retrieval is timely and relevant.]
#v(0.25em)
- *Purpose:* preserve information beyond the current conversation (e.g., document collections, databases).
- *Mechanism:* (Typically) implemented via #underline[Retrieval-Augmented Generation (RAG)].
  - _Retrieve:_ match the user's query against an external store (like a vector database).
  - _Augment:_ select the most relevant chunks and inject them into the context window.
  - _Generate:_ allow the model to reason and answer using this newly injected knowledge.
- *Quality factors:* freshness of information, provenance (sources), and retrieval relevance.
#align(center)[
  #image("figures/rag.png", width: 40%)
]
== RAG in Practice: Ingestion vs. Retrieval

- #keyline-blue[RAG is split into two distinct stages: offline indexing and online retrieval.]
#v(0.25em)
- *Indexing* (_offline_): pre-processes domain documents.
  - Documents are cleaned, parsed, and split into smaller segments (#keyline-green[chunking]).
    - #text(size: 0.72em, fill: rgb("#4a5568"))[_Chunking:_ cuts long texts into cohesive segments fitting the context window.]
  - Each segment is converted into a numeric vector (#keyline-green[embedding]) and stored.
    - #text(size: 0.72em, fill: rgb("#4a5568"))[_Embedding:_ converts text into numeric coordinates representing semantic concepts.]
- *Retrieval* (_online_): runs dynamically when a user submits a query.
  - The query is vectorized using the same #underline[embedding model].
  - A specialized #keyline-green[vector store] finds and returns semantically similar segments.
    - #text(size: 0.72em, fill: rgb("#4a5568"))[_Vector Store:_ database optimized for high-speed semantic similarity searches.]
  - Relevant segments are injected directly into the LLM prompt context.
#v(0.15em)
- For both stages, the choice of #underline[embedding model] (semantic depth), #underline[chunking strategy] (segment size), and #underline[vector store] (retrieval architecture) directly determines retrieval precision and relevance.
== LangChain4j: Easy RAG - Ingestion

- #keyline-green[The ingestion stage parses, chunks, and vectorizes documents into a store.]
#v(0.25em)
- *Process:*
  - Load documents from a directory using `FileSystemDocumentLoader`.
  - Instantiate a lightweight vector store (e.g., in-memory or external).
  - Use `EmbeddingStoreIngestor` to automatically handle segment splitting, embedding generation, and database storage.

```scala
// Load all text files from a folder
val docs = FileSystemDocumentLoader.loadDocuments("/docs")

// Initialize an in-memory vector store
val store = new InMemoryEmbeddingStore[TextSegment]()

val embeddingModel = ...
val ingestResult = EmbeddingStoreIngestor.builder()
  .embeddingModel(embeddingModel)
  .embeddingStore(store)
  .build()
  .ingest(docs)

```

== LangChain4j: Easy RAG - Retrieval

- #keyline-green[The retrieval stage dynamically queries the store and answers via AI Services.]
#v(0.25em)
- *Process:*
  - Configure an `EmbeddingStoreContentRetriever` to link the model with the store.
  - Bind the retriever to the declarative `AiServices` builder.
  - Call the service: relevant context is retrieved and injected automatically.

```scala
// Create a retriever linked to our database
val retriever = EmbeddingStoreContentRetriever.builder()
  .embeddingStore(store)
  .embeddingModel(embeddingModel) // Default mini model
  .maxResults(3) // Retrieve top 3 relevant chunks
  .build()

// Bind the retriever to the AI Service
val assistant = AiServices.builder(classOf[Assistant])
  .chatModel(model)
  .contentRetriever(retriever)
  .build()

val answer = assistant.chat("How does our system work?")
```
#divider(
  [Part V · Agents],
  [Combine tools and memory to build agentic systems.],
  subtitle: [Goal decomposition, planning, tool integration, and stateful reasoning loops.],
)

== Workflows vs. Pure Agents

- #keyline-blue[Anthropic's taxonomy] groups agentic system architectures into two main paradigms:
#v(0.25em)
- *Workflows:* Orchestration of LLMs and tools via #underline[deterministic, hardcoded paths]
  - _Structure:_ Sequences, loops, parallel execution, and conditional branches
  - _Trade-offs:_ Extremely predictable, highly reliable, easy to test, but rigid
- *Pure Agents:* The LLM acts as an autonomous #underline[reasoning core and planner]
  - _Structure:_ The agent dynamically decides which tool or subagent to call next based on state
  - _Trade-offs:_ High flexibility, extremely adaptive, handles unexpected edge cases, but harder to predict and verify
#v(0.25em)
- #highlight[Practical perspective:] start with workflows, introduce pure agency only for high-complexity, unstructured decisions

== LangChain4j Agents: Core Primitives

- #keyline-blue[The `@Agent` annotation] is the declarative building block for agentic systems:
#v(0.25em)
- In LangChain4j, an agent is defined as an interface (similar to an AI Service)
- Subagents can write results to a #underline[shared state] and read input from previous steps

```scala
// Define a specialized agent interface in Scala 3
trait CreativeWriter:
  @UserMessage(Array("""
    You are a creative writer.
    Generate a story about the topic: {{topic}}.
  """))
  @Agent("Generates a story based on a given topic")
  def generateStory(@V("topic") topic: String): String
```

- `@V` binds method parameters to prompt template variables (like `{{topic}}`)
- Compilation with `-parameters` allows omitting `@V` (automatically inferred from parameter names)

== The `AgenticScope`: Shared State

#definition-line[
  An #underline[AgenticScope] is a stateful blackboard containing data shared among the subagents participating in an agentic system
]
#v(0.35em)
- _Shared Blackboard:_ Agents read required inputs from the scope and write results back using `outputKey`
- _Automatic Registry:_ Automatically logs the exact sequence of agent invocations and their raw outputs
- _Persistence & Recovery:_ The scope can be serialized, persisted, and reloaded to recover a multi-turn process from failure
#v(0.25em)
- #highlight[In practice:] the scope decouples agent execution from orchestration routing

== Deterministic Workflows: Sequential & Loops

- #keyline-blue[Sequential Workflow:] Execute subagents one after another:

```scala
val creativeWriter = AgenticServices.agentBuilder(classOf[CreativeWriter])
  .chatModel(model).outputKey("story").build()

val audienceEditor = AgenticServices.agentBuilder(classOf[AudienceEditor])
  .chatModel(model).outputKey("editedStory").build()

// Combine into a sequence
val novelCreator = AgenticServices.sequenceBuilder()
  .subAgents(creativeWriter, audienceEditor)
  .outputKey("editedStory").build()
```

- #keyline-blue[Loop Workflow:] Iteratively refine output until a condition is met:

```scala
val styleReviewLoop = AgenticServices.loopBuilder()
  .subAgents(styleScorer, styleEditor)
  .maxIterations(5)
  .exitCondition(scope => scope.readState("score", 0.0) >= 0.8)
  .build()
```

== Workflows: Parallel, Mappers, and Branches

- #keyline-blue[Parallel Workflow:] Run independent agents concurrently:

```scala
val eveningPlanner = AgenticServices.parallelBuilder()
  .subAgents(foodExpert, movieExpert)
  .executor(Executors.newFixedThreadPool(2))
  .output(scope => combinePlans(scope.readState("movies"), scope.readState("meals")))
  .build()
```

- #keyline-blue[Parallel Mapper:] Run the *same* agent concurrently across a collection:
  - _Note:_ For concurrent safety, subagents in parallel mappers cannot have `ChatMemory`
- #keyline-blue[Conditional Branching:] Execute different agents based on scope state:

```scala
val routerAgent = AgenticServices.conditionalBuilder()
  .subAgents(scope => scope.readState("category") == "MEDICAL", medicalExpert)
  .subAgents(scope => scope.readState("category") == "LEGAL", legalExpert)
  .build()
```

== Pure Agentic AI: The Supervisor Pattern

- #keyline-blue[A Supervisor Agent] uses an LLM planner to orchestrate subagents dynamically:
#v(0.25em)
- Instead of rigid routes, the supervisor determines the next agent to invoke based on #underline[context]
- It communicates via structured `AgentInvocation` requests and observes outcomes in a loop
#v(0.25em)

```scala
val bankSupervisor = AgenticServices.supervisorBuilder()
  .chatModel(plannerModel)
  .subAgents(withdrawAgent, creditAgent, exchangeAgent)
  .responseStrategy(SupervisorResponseStrategy.SUMMARY)
  .build()

// Supervisor creates a plan, calls agents, and terminates when finished
bankSupervisor.invoke("Transfer 100 EUR from Mario to Georgios")
```

== Supervisor Customization & Policies

- #keyline-blue[Response Strategy:] Choose how the final result is determined:
  - `LAST`: Returns the response of the last executed subagent (default)
  - `SUMMARY`: Returns the supervisor's transactional summary of operations
  - `SCORED`: Uses an LLM scorer to choose the best response between the two

- #keyline-blue[Context Policies:] Guide the supervisor's planning with rules or preferences:

```scala
// Provide policies via builder or dynamically at invocation time
val supervisor = AgenticServices.supervisorBuilder()
  .chatModel(plannerModel)
  .supervisorContext("Policies: Prefer internal tools, currency is USD")
  .subAgents(withdrawAgent, creditAgent)
  .build()
```

- Overriding can be done per-invocation by passing `supervisorContext` as an argument


#divider(
  [Part VI · Verification],
  [Power without verification is not engineering.],
  subtitle: [Evaluate both the final answer and the trajectory that produced it.],
)

== Why Verify Agentic AI Systems?

- #keyline[Agent loops are multi-step, stateful, and non-deterministic.]
#v(0.25em)
- _The failure of traditional assertions:_
  - Unit testing assumes deterministic, reproducible state-to-state mappings.
  - Models behave as black-boxes with probabilistic output spaces.
  - Small changes in prompts can cause catastrophic, silent regressions.
- _State space complexity:_
  - Dialogue histories and intermediate tool responses create an #underline[infinite state space].
  - An agent can traverse many #underline[different trajectories] to produce the same final answer, or vice versa.
- _Error propagation (Cascading Failures):_
  - A minor reasoning or tool-call error in step $i$ propagates and amplifies through subsequent steps.
#v(0.15em)
$arrow.r$ we must evaluate the #underline[entire trace] of the interaction, not just the final output.

== The 3-Stage Evaluation Loop

- #keyline-green[Evaluations should run continuously at different granularities and speeds:]
#v(0.25em)
- _Level 1: Unit Tests & Assertions_ (Deterministic Filter)
  - Programmatic, zero-LLM checks run on every code change (CI/CD pipeline).
  - Ensures compliance with JSON schemas, regex constraints, and system-level latency bounds.

- _Level 2: Model & Human-in-the-Loop_ (Semantic Validation)
  - Evaluation of semantic correctness and multi-step reasoning against a curated #underline[Golden Dataset].
  - Uses domain-specific LLM-as-a-Judge systems calibrated by human expert feedback.

- _Level 3: Production Telemetry & Monitoring_ (Statistical Safety)
  - Real-world validation via continuous tracking of live user interactions.
  - Monitors implicit feedback, tool exception rates, model drift, and semantic divergence.

== Level 1: Functional Correctness via pass\@k

- #keyline-green[Estimating performance under non-deterministic generation:]
#v(0.25em)
- _The Metric:_ fraction of problems solved when generating $k$ candidate solutions. A problem is considered solved if #underline[at least one] sample passes verification.
- _The Unbiased Estimator:_ rather than drawing $k$ samples directly (high variance), we generate $n$ samples ($n >= k$), count successful candidates $c$ passing verification, and use:
  $ "pass@k" = E [1 - (binom(n-c, k)) / (binom(n, k))] = 1 - (binom(n-c, k)) / (binom(n, k)) $
- _Generalization to LLM-as-a-Judge (next):_
  - Not restricted to code unit tests.
  - We can use an #underline[LLM-as-a-Judge] as the automated validator to compute pass\@k on semantic or free-text generation, measuring how often at least one of the $k$ generated runs is approved by the judge.
- _The Temperature Trade-off:_
  - For #underline[pass\@1], use #underline[low temperature] (0.0 to 0.2) to minimize bad paths.
  - For high $k$ (e.g., #underline[pass\@10]), use #underline[high temperature] (0.7+) to maximize sample diversity, increasing the probability that at least one candidate passes.

== Level 2: Curation of a "Golden Dataset"

#definition-line[
  A *Golden Dataset* is a highly curated, diverse dataset of 20-100 high-value test cases reviewed and validated by domain experts to represent the system's operational envelope
]
#v(0.25em)
- #keyline-green[Start with high density of concepts rather than large volume of noisy data:]
- _Dimensional coverage (Subspace testing):_
  - _Core Capabilities:_ explicit tests for tool calling, reasoning, and routing.
  - _User Diversity:_ variations in user skill levels, writing style, and formatting.
  - _Edge Scenarios:_ adversarial queries, out-of-distribution inputs, and system prompt attacks.
- _Continuous Curation Cycle:_ the dataset is a living asset. As new failure modes are uncovered in production (Level 3), they are distilled and backported into the Golden Dataset.

== Level 2: Critique Shadowing with Domain Experts

- #keyline-green[How to establish an evaluation baseline with high inter-annotator agreement:]
#v(0.2em)
- Pay attention to the evaluation interface design:
  - 1-5 numerical ratings suffer from extreme cognitive bias and low #underline[Cohen's Kappa] (agreement rates).
  - Different experts interpret a "3" or a "4" differently, introducing massive noise.
- _Binary Judgments:_ experts are asked only: _"Is this output ready for production?"_
- _Critique Capturing:_ if the expert flags a failure, they #underline[must] write a concise, one-sentence critique explaining the specific reason (e.g., _"Over-promised refund without checking order state"_).
#v(0.15em)
- #highlight[The Golden Rule:] human-written critiques provide the precise, qualitative instructions and few-shot examples needed to align your automated LLM judge.

== Level 2: Building an LLM-as-a-Judge System

- #keyline-green[Calibrating a domain-specific model judge to match human expert standards:]
#v(0.2em)
- _Critique-First Prompting:_
  - Asking an LLM for a binary verdict directly leads to high false-positive rates.
  - We force the model to write the #underline[critique first] (Chain of Thought reasoning), and only then output the final #underline[verdict] (PASS/FAIL).
- _Few-Shot Real Alignment:_ inject actual human-annotated critiques and verdicts directly into the system prompt to calibrate the judge's boundary conditions.
- _Human-to-Model Agreement KPI:_ run the judge on the Golden Dataset, measure agreement, and perform systematic error analysis to reconcile gaps.
- _Deconstruction of Complex Rubrics:_ break down general evaluations into a cascade of independent, specialized, binary judges (e.g., Tone, Accuracy, Policy Compliance).

== Level 2: RAG Evaluation - The RAGAs Triad

- #keyline-green[Isolating retrieval failures from generation failures via three specialized metrics:]

#align(center)[
  #image("figures/rag.png", width: 30%)
]
#v(-0.35em)
- _Faithfulness (Groundedness):_ measures if the generated claims are supported #underline[only] by the retrieved context. Prevents generator hallucination. (Answer vs. Context).
- _Answer Relevance:_ measures if the generated answer directly resolves the user query without omitting key requests or adding irrelevant fluff. (Answer vs. Query).
- _Context Recall & Precision:_
  - _Context Recall:_ percentage of ground-truth facts successfully retrieved. Measures if the retriever missed critical information. (Context vs. Ground Truth).
  - _Context Precision:_ signal-to-noise ratio of retrieved chunks. Measures if the retriever fetched irrelevant context that wastes model tokens. (Context vs. Query).

== Verifying the Trajectory: Tool Calls

- #keyline[In multi-step agents, the path taken is as important as the final answer:]
#v(0.25em)
- _Tool Selection Accuracy:_ evaluated via classification metrics (Precision, Recall, F1-Score) comparing expected tools against actual agent tool-call traces.
- _Argument Boundary Checking:_ validates that arguments emitted by the model fall within safe, expected ranges and schemas (preventing SQL/command injection).
- _Observation Grounding:_ measures if the agent's next reasoning step is logically coherent with the tool's output, or if it ignores facts/hallucinates past them.
- _Exception Recovery (Self-Correction):_ injects simulated tool exceptions (e.g., API timeouts, rate limits) to verify if the agent's planner gracefully recovers, falls back to other tools, or reports failure cleanly.
#v(0.15em)
- #highlight[Remember:] a correct answer reached through an inefficient or unsafe tool loop is still an engineering failure.

== Level 3: Monitoring & Production Observability

- #keyline[Production systems require deep, hierarchical visibility into live reasoning traces:]
#v(0.2em)
- _Trace Instrumentation (OpenTelemetry-native):_
  - Spans must capture the #underline[hierarchical, nested] nature of agent loops.
  - *Tracing Flow:* User Query $arrow$ Planning Node $arrow$ Sub-Agent Spawn $arrow$ Tool Execution $arrow$ Observation $arrow$ Generation.
  - *Modern Tooling:* #keyline-green[LangSmith], #keyline-green[Langfuse], #keyline-green[Arize Phoenix] (via #keyline-blue[OpenLLMetry] spans).
- _Low-Level Execution Logging (e.g., ChatModelListener):_
  - Collects precise context (raw prompts, system instructions, token counts, cost, temperature, latency) and aggregates low-level performance KPIs.
- _Production Telemetry Analysis:_
  - *Exception Rates:* monitors tool/API errors to catch breaking changes in external systems.
  - *Semantic Drift:* automatically flags incoming queries deviating from the evaluation Golden Set.
  - *Trace Filtering:* surfaces high-latency traces and negative user feedback (e.g., thumbs down) for manual curation.

== Conclusions

- #keyline-blue[Evaluating multi-step reasoning] requires accounting for stochasticity, non-determinism, and complex tool trajectories.
- In this lesson, we explored #keyline-green[practical techniques] to evaluate, build, and observe these agents in practice.
#v(0.15em)
- _Key Dimensions for Real-World Deployment:_
  - _Model Versioning:_ track behavioral changes over time to establish robust LLMOps pipelines.
  - _Advanced Observability:_ integrate trace analysis tools (e.g., LangSmith) for production visibility.
  - _Robust Verification:_ leverage simulation environments, synthetic datasets, and adversarial testing.
- _Related Frameworks & Advanced Concepts:_
  - #keyline-blue[LangSmith] (https://smith.langchain.com/): industry-standard platform for tracing and evaluation.
  - #keyline-blue[Model Context Protocol (MCP)]: standardized open protocol to decouple models from tool-execution details.
  - #keyline-blue[Agent-to-Agent (A2A) Communication]: patterns for orchestrating complex, collaborative multi-agent systems.

