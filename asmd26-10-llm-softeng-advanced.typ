#import "@preview/touying:0.7.3": *
#import "themes/theme.typ": *
#import "@preview/fontawesome:0.6.0": *
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

#set text(font: "Source Sans Pro", weight: "regular", size: 20pt)
#show math.equation: set text(font: "Fira Math")
#show strong: set text(fill: rgb("#005587"))
#show emph: set text(style: "italic", fill: rgb("#00a3e0"))
#set underline(stroke: 1.5pt + rgb("#005587"), offset: 2pt)
#let highlight(body) = box(
  fill: rgb("#fff1a8"),
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
#let keyline(body) = highlight[#text(size: 0.96em, fill: rgb("#23373b"))[#body]]
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

- #highlight[*Guiding question*:] how can a language model _perceive_, _decide_, _act_, _remember_, and remain _verifiable_?
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
    - In LLM-based agents, objectives are often expressed as natural-language instructions
  ]
  
#v(0.25em)
- #underline[Key point:] agency is defined by the full #keyline[perception-action loop], not by intelligence alone

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

- #highlight[Takeaway:] these properties distinguish agentic systems from static question-answering or single-turn chat
#align(center)[
  #image("figures/single-turn-interaction.png", width: 50%)
]

== Building Blocks of an Agentic AI System

- #keyline[An agentic system works only when model, tools, memory, and orchestration remain #underline[aligned]]
- _Reasoning layer_ - #underline[LLM]: interprets the goal, plans candidate actions, and synthesizes answers
- _Action layer_ - #underline[Tools]: expose external capabilities such as search, APIs, databases, or code execution
- _Continuity layer_ - #underline[Memory]: preserves information across steps and across interactions
- _Control layer_ - #underline[Orchestration]: translates model outputs into executable operations and returns observations

#align(center)[
  #image("figures/agent-revised.png", width: 45%)
]


== LangChain4j: AI Services

- #keyline[AI Services are the first high-level abstraction above raw chat interactions]
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
  A *tool* is a callable resource outside the model, exposed through a well-defined interface
]
- A tool is not stored #keyline[inside] the model parameters; it is made available by the surrounding software system
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

- #keyline[Tools improve both epistemic quality and operational reach]
- *Grounding:* tools can reduce hallucination by connecting answers to external information sources
  - Before replying, the model can check facts, compute results, or query databases instead of relying solely on internal knowledge (_self-augmentation_ and _self-correction_ patterns)
- *Capability extension:* tools enable actions that plain text generation cannot perform #underline[reliably] on its own
  - e.g., performing calculations, or manipulating structured data
- *System interaction:* tools let the agent read from and write to *real* systems
- *Observability:* tool schemas make #underline[behavior] easier to inspect and evaluate
#v(0.25em)
- #highlight[Takeaway:] tools move the model from isolated text generation toward controlled interaction with the world


== A Tool Is a Contract

- #keyline[Tool quality depends partly on prompt design and partly on interface design.]
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
- An `AIService` can include this `Calculator` as a #keyline[capability]:
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
- #keyline[Annotations are used to generate the tool's JSON schema.]
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
- #keyline[The orchestration layer converts #underline[language] into execution and execution back into #underline[context]]
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

- #keyline[Core loop:] task -> action request -> execution -> observation -> continuation.
#v(0.25em)
- *Historical baseline:* zero-shot tool use described tools directly in the prompt and asked the model to emit a textual pseudo-command.
  - The prompt had to specify tool names, descriptions, call format, and the user task.
  - #highlight[Limitation:] formatting errors became execution errors.
#v(0.25em)
- *Current practice:* many modern models already support this #underline[ReAct-style loop] natively.
  - They decide when a tool is needed, emit a structured request, observe the result, and continue reasoning.
- *Function calling* is the usual interface: the model returns a typed function name with validated arguments instead of fragile free text.
- Frameworks such as _LangChain4j_ help normalize provider-specific tool-calling APIs at the application level.

== LangChain4j: Conceptual Tool-Use Flow

- #keyline[The framework mediates between application capabilities and provider-specific model interfaces]
#v(0.25em)
- *Developer side:* the application exposes a set of callable capabilities
- *Framework side:* those capabilities are presented to the model in a provider-compatible form
- *Model side:* the model decides whether a tool is needed and emits a structured request
- *Runtime side:* the selected tool is executed and the result is captured
- *Conversation side:* the result is reintroduced into the interaction so reasoning can continue
#v(0.25em)
- #highlight[Takeaway:] the framework coordinates the loop between model, tool, and application logic
- _Editorial hint:_ TODO sequence diagram of model request, runtime execution, tool result, and final answer

#divider(
  [Part III · Memory],
  [Memory turns interaction into continuity.],
  subtitle: [Conversation state, working state, retrieval, and context injection.],
)

== Memory in Agentic AI Systems

- #keyline[Memory matters because the current prompt is rarely enough.]
#v(0.25em)
#definition-line[
  *Memory* is the mechanism by which an agent stores, retrieves, and reuses information across reasoning steps or across interactions.
]
- Memory supports continuity, personalization, planning, and retrieval of prior knowledge.
- A useful distinction is between *short-term memory*, *working memory*, and *long-term memory*.
#v(0.25em)
- _Editorial hint:_ TODO taxonomy figure for the main types of memory.

== Short-Term Memory: Conversation History

- #keyline[Conversation history is useful only when it remains selective.]
#v(0.25em)
- *Purpose:* preserve recent context across turns.
- *Typical content:* user goals, previous answers, prior tool outputs, and unresolved constraints.
- *Benefit:* the model interprets the current turn in light of recent interaction.
- *Failure mode:* blindly storing the full transcript often adds noise rather than clarity.
#v(0.25em)
- #underline[Rule:] short-term memory should be selective, because irrelevant context consumes tokens and can confuse the model.

== Working Memory: Intermediate State

- #keyline[Working memory supports the task in progress, not the whole user relationship.]
#v(0.25em)
- *Purpose:* hold temporary artifacts needed during the current task.
- *Examples:* a plan, extracted entities, partial computations, or pending subtasks.
- *Role:* separate durable knowledge from intermediate reasoning state.
- *Risk:* stale intermediate state can mislead later steps if it is not updated or discarded carefully.
#v(0.25em)
- #highlight[Design issue:] working memory must be actively maintained, not merely accumulated.

== Long-Term Memory: Knowledge Base

- #keyline[Long-term memory is valuable only if retrieval is timely and relevant.]
#v(0.25em)
- *Purpose:* preserve information beyond the current conversation.
- *Implementations:* document collections, vector stores, databases, or symbolic knowledge bases.
- *Access principle:* long-term memory becomes useful only when the system can *retrieve* relevant items at the right moment.
- *Quality factors:* freshness, provenance, indexing quality, and access policy.
#v(0.25em)
- #underline[Key distinction:] storage alone is not enough; effective memory requires retrieval and context injection.
- _Editorial hint:_ TODO retrieval pipeline diagram from query to retrieved context.

== Memory Pipeline in Practice

- #keyline[The pipeline matters more than the storage technology alone.]
#v(0.25em)
- *Store:* decide what information deserves persistence.
- *Index:* organize stored content for efficient retrieval.
- *Retrieve:* select the subset relevant to the current goal.
- *Inject:* add retrieved context to the model input in a usable form.
- *Evaluate:* measure whether memory improved performance or simply added noise.

== LangChain4j: Conceptual Memory Flow

- #keyline[The model does not query storage directly; the application mediates memory access.]
#v(0.25em)
- *Conversation side:* the framework can help maintain recent interaction state.
- *Retrieval side:* it can also mediate access to external knowledge sources.
- *Policy side:* the application still decides what is stored, what is retrieved, and when memory is injected.
- *Reasoning side:* the model reasons over the *provided context*, not over the storage backend directly.
#v(0.25em)
- #highlight[Takeaway:] memory is an orchestration policy as much as it is a storage mechanism.
- _Editorial hint:_ TODO comparison figure of conversation memory versus retrieval-based memory.

#divider(
  [Part IV · Verification],
  [Power without verification is not engineering.],
  subtitle: [Evaluate both the final answer and the trajectory that produced it.],
)

== Why Verify Agentic AI Systems?

- #keyline[More capability means more observable failure modes.]
#v(0.25em)
- Agentic systems are more powerful than single-shot chat systems, but they also introduce more places where behavior can fail.
- Errors can arise in reasoning, tool choice, argument construction, execution, retrieval, or final answer synthesis.
- Therefore, inspecting only the final answer is often insufficient.
#v(0.25em)
- #highlight[Verification target:] we must evaluate both the *outcome* and the *trajectory* that produced it.

== What Must Be Verified?

- #keyline[Verification spans the full interaction trace.]
#v(0.25em)
- *Before execution:* did the agent choose the right tool and construct valid arguments?
- *During execution:* did the tool run successfully and return interpretable results?
- *Across context:* was relevant memory retrieved without contamination or omission?
- *After execution:* is the final answer correct, grounded, complete, and aligned with constraints?

== How Can We Verify It?

- #keyline[No single evaluation method is sufficient.]
#v(0.25em)
- *Component-level checks:* unit tests can validate tool wrappers, schemas, and error handling.
- *Task-level checks:* scenario-based tests can evaluate multi-step behavior on representative tasks.
- *Quantitative monitoring:* metrics can track success rate, grounding quality, tool-call accuracy, latency, and cost.
- *Judgment and governance:* human review remains important for ambiguous, high-stakes, or safety-critical cases.
#v(0.25em)
- #underline[Best practice:] combine automated evaluation with targeted human inspection.
- _Editorial hint:_ TODO verification matrix matching failure modes to evaluation methods.

== Final Perspective

- #keyline[The engineering problem is to make capability inspectable and dependable.]
#v(0.25em)
- Agentic AI is a problem of *system design*, not only of model capability.
- *Tools* provide action, *memory* provides continuity, and *verification* provides trust.
- Frameworks such as _LangChain4j_ help implement these loops, but the engineering choices still determine reliability.
#v(0.25em)
- #highlight[Final takeaway:] robust agentic systems are built through explicit architectures, explicit interfaces, and explicit evaluation.

#focus-slide(align: left + horizon)[
  #kicker[Final takeaway]
  #v(0.55em)
  #text(size: 1.38em, weight: "medium")[Build agentic AI as an explicit system.]
  #v(0.75em)
  #text(size: 0.82em, fill: rgb("#d7e6ef"))[
    *Tools* provide action. *Memory* provides continuity. *Verification* provides trust.
  ]
]
