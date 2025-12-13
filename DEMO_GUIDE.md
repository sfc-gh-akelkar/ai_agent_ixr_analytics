## PatientPoint Predictive Maintenance — Demo Guide

### The One-Liner (memorize this)
> "Snowflake turns screen telemetry into **early warning, predicted failures, and automated fixes**—so PatientPoint can **protect ad revenue, cut field costs, and eliminate surprise outages**."

---

## Before You Present: Mindset

**This is not a product demo. This is a story about money.**

| PatientPoint cares about... | You show... |
|-----------------------------|-------------|
| **Make money** | Revenue protected by avoiding downtime |
| **Save money** | Field dispatches avoided via remote fixes |
| **Reduce risk** | Predictable operations, governed AI, no surprises |

Every prompt you ask should tie back to one of these.

---

## Demo Setup (do this 5 minutes before)

1. Open **Snowflake Intelligence → Agents → MAINTENANCE_OPS_AGENT**
2. Clear any previous chat history
3. Have these 8 prompts ready to copy/paste (or memorize):

| # | Prompt |
|---|--------|
| 1 | What device is in the worst shape right now? |
| 2 | For that device, show me the last 7 days of temperature, power, and error trends. |
| 3 | Zoom out: show me fleet health—how many devices are critical, warning, and on the watchlist? |
| 4 | Which devices are predicted to fail in the next 48 hours? Show probability and failure type. |
| 5 | What P1 work orders are open? Which require field dispatch vs remote fix? |
| 6 | For the top remote work order, show me the step-by-step runbook. |
| 7 | What fixes have worked historically for network connectivity issues? |
| 8 | How much revenue and cost impact have we seen in the last 30 days? Include the assumptions behind any estimates. |

---

## The 20-Minute Script

---

### 0:00–1:30 — The Hook (No Slides, No Agent—Just Story)

**Say this:**

> "Let me paint a picture.
>
> It's Monday morning. You get a call from a pharma partner—'Our campaign didn't hit impressions this weekend. What happened?'
>
> You check the system. Turns out 47 screens went down Friday night. No one knew. By the time field techs were dispatched, you lost $15,000 in ad delivery, the partner is frustrated, and your ops team spent the weekend firefighting instead of with their families.
>
> That's the **reactive model**. And it's expensive—not just in dollars, but in trust.
>
> Today I'm going to show you how to **never have that Monday morning call again**."

**Then say (Snowflake positioning):**

> "What makes this possible is Snowflake. Not just as a database—but as a **governed system of intelligence**: your data, your business logic, your AI, and your operational workflows—all in one place, all auditable, all explainable."

---

### 1:30–4:00 — One Device in Crisis (The Zoom-In)

**Say:**

> "Let's start with what matters right now. Is anything on fire?"

**Prompt 1:**
```
What device is in the worst shape right now?
```

*Wait for response. The agent will surface a critical device (e.g., Device 4532).*

**Say:**

> "This is Device 4532. The system is telling us it's in trouble. But *why*? Let's look under the hood."

**Prompt 2:**
```
For that device, show me the last 7 days of temperature, power, and error trends.
```

*Wait for response. Point to the trends.*

**Say:**

> "See that? Temperature climbing, power spikes, error rate doubling. In the old world, you'd find out when the clinic calls. Now you know **before it fails**—and you can do something about it."

---

### 4:00–6:00 — Zoom Out to the Fleet (The Scale)

**Say:**

> "That's one device. But PatientPoint has thousands. Let's zoom out."

**Prompt 3:**
```
Zoom out: show me fleet health—how many devices are critical, warning, and on the watchlist?
```

*Wait for response.*

**Say:**

> "So right now, we have [X] critical, [Y] on the watchlist. The watchlist isn't just 'devices with problems'—it's devices **drifting from their own baseline**. That's early warning. You catch issues before they become outages."

---

### 6:00–9:00 — Prediction + Prioritization (The Proactive Shift)

**Say:**

> "Early warning is great. But the real unlock is: **what's going to fail in the next 24–48 hours?** That's how you schedule work, stage parts, and staff your team—before the downtime hits."

**Prompt 4:**
```
Which devices are predicted to fail in the next 48 hours? Show probability and failure type.
```

*Wait for response.*

**Say (pointing to a high-probability device):**

> "Device 4556—61% probability of power supply failure. That's not a guess. That's based on anomaly patterns we've seen lead to failures in historical data. Now I can schedule a tech **tomorrow**, not after the screen goes black."

**If asked "Is this real ML?":**

> "In this demo, the scoring uses explainable heuristics so you can see exactly *why* a device is flagged. In production, you swap in Snowpark ML models—same data, same agent, same workflow. The foundation doesn't change."

---

### 9:00–12:00 — The Ops Queue (Turning Insight into Action)

**Say:**

> "Predictions are great, but operations teams don't work from predictions—they work from **work orders**. So let's see what's actionable right now."

**Prompt 5:**
```
What P1 work orders are open? Which require field dispatch vs remote fix?
```

*Wait for response.*

**Say:**

> "See the split? Some of these can be fixed remotely—no truck roll, no $500 dispatch. Others need a field visit, and we've already staged the right parts because we know the failure type.
>
> This is where **money gets saved**. Every remote fix = one avoided dispatch. Every predicted failure = one avoided outage."

---

### 12:00–15:00 — The Magic Moment (Remote Fix Live)

**Say:**

> "Now the 'wow' moment. Let's actually fix something.
>
> *Important context*: In a demo, we're not running real commands on real devices. But what I'm about to show you is the **full operating model**—how a predicted failure becomes an automated fix with an audit trail.
>
> In production, this same workflow calls your MDM or RMM tooling and updates your ServiceNow tickets. Today, we'll walk through what that looks like."

**Prompt 6:**
```
For the top remote work order, show me the step-by-step runbook.
```

*Wait for response.*

**Say (pointing to the steps):**

> "Step 1: collect network stats. Step 2: reset interface. Step 3: verify recovery. Each step is logged. If it fails, it escalates to field service automatically—with the context attached.
>
> **Before AI**: device fails → clinic calls → you dispatch → 6 hours of downtime → $500 cost.
>
> **After AI**: device flagged → remote fix triggered → resolved in minutes → no downtime → no cost.
>
> That's the difference."

---

### 15:00–17:30 — Grounding (The Agent Isn't Guessing)

**Say:**

> "A common question: 'How do I know the AI isn't making things up?'
>
> Fair question. Let me show you how it's grounded."

**Prompt 7:**
```
What fixes have worked historically for network connectivity issues?
```

*Wait for response.*

**Say:**

> "The agent pulled this from a **searchable knowledge base** of past incidents. It's not hallucinating—it's citing real outcomes. 95% remote success rate for network issues. That's why we route network problems to remote first.
>
> Every answer is either from a **semantic view** (structured data) or the **knowledge base** (historical incidents). No raw table access. No guesswork. Governed and auditable."

---

### 17:30–19:30 — The ROI (Show the Money)

**Say:**

> "Let's bring it back to business outcomes."

**Prompt 8:**
```
How much revenue and cost impact have we seen in the last 30 days? Include the assumptions behind any estimates.
```

*Wait for response.*

**Say (pointing to the response):**

> "Two things to note:
>
> 1. **Observed metrics**—downtime hours, revenue impact, field vs remote events—come directly from incident data. These are real.
>
> 2. **Estimated savings**—revenue protected, field cost avoided—are driven by an **explicit assumptions table**. You can see the assumptions right here: $120/hour ad revenue impact, $500/dispatch. We can edit these live to match PatientPoint's actual numbers.
>
> We don't fabricate ROI. We show you the math."

---

### 19:30–20:00 — The Close (Ask for Commitment)

**Say:**

> "So here's what we've seen today:
>
> - Devices in trouble **before** they fail. *(Pause)* Does that matter to you?"

*Wait for nod/affirmation.*

> - Automated triage so your team works on **what matters**. *(Pause)* Useful?"

*Wait for nod/affirmation.*

> - Field dispatches cut because **remote fixes work**. *(Pause)* Worth exploring?"

*Wait for nod/affirmation.*

> "Great. Here's the next step:
>
> A **2-hour workshop** with your real telemetry data. We connect it, run the same watchlist, and show you **your** critical devices—not demo data.
>
> Can we get that on the calendar this week?"

---

## Objection Handling (Keep These Ready)

### "Is this real ML?"

> "The demo uses explainable heuristics so you can see the 'why' behind every flag. In production, you plug in Snowpark ML or Cortex ML models—same data foundation, same agent, same workflow. We designed it to be swappable."

### "Are the savings real?"

> "Observed metrics—downtime, incidents, costs—come from your incident history. Estimated savings are driven by an assumptions table you can edit. We show the math; we don't make it up."

### "What does productionization look like?"

> "Three things: (1) Connect your live telemetry stream, (2) integrate remote runbooks with your MDM/RMM tooling, (3) connect work orders to your ticketing system. The Snowflake foundation—data, governance, semantic layer, agent—stays the same."

### "How long to deploy?"

> "The data foundation and agent can be stood up in weeks. Integration with your endpoint tooling and ticketing system depends on your existing stack—typically 4–8 weeks for a production pilot."

---

## Backup Prompts (If You Have Extra Time)

| Scenario | Prompt |
|----------|--------|
| They want to see a specific device | "Show me everything about device [ID]: status, trends, predictions, and similar past incidents." |
| They want to see the assumptions table | "What assumptions drive the cost and revenue estimates? Can I see the table?" |
| They want to see escalation logic | "When does a remote fix escalate to field service? Show me an example." |
| They want to see the KB search | "Find incidents similar to device 4512 and summarize the top troubleshooting steps." |

---

## One-Page Cheat Sheet (Print This)

| Time | Beat | Prompt | Money Hook |
|------|------|--------|------------|
| 0–1:30 | Hook | *(Story—no prompt)* | "Never have that Monday call again" |
| 1:30–4:00 | One device | "What device is in the worst shape?" | "Before it fails" |
| 4:00–6:00 | Fleet | "Zoom out: fleet health" | "Early warning at scale" |
| 6:00–9:00 | Predictions | "Predicted failures in 48h" | "Schedule work before downtime" |
| 9:00–12:00 | Ops queue | "P1 work orders—remote vs field" | "Every remote fix = $500 saved" |
| 12:00–15:00 | Magic moment | "Step-by-step runbook for top remote" | "Crisis to resolution in minutes" |
| 15:00–17:30 | Grounding | "What's worked for network issues?" | "Governed, not guessing" |
| 17:30–19:30 | ROI | "Revenue and cost impact + assumptions" | "We show the math" |
| 19:30–20:00 | Close | *(Ask for workshop)* | "Your data, your devices, this week" |

---

## Final Reminders

1. **Slow down.** Let the agent responses breathe. Silence is powerful.
2. **Point to the screen.** "See that? That's the signal." Physical gestures anchor attention.
3. **Use their language.** If they say "dispatch," you say "dispatch." If they say "truck roll," you say "truck roll."
4. **End with a question.** Never end on a statement. "Can we get that workshop scheduled?" gets a yes or a conversation.

Good luck. Go wow them.
