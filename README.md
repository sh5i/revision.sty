# revision.sty

A LaTeX package for revising a paper in response to peer review.
It links the revised manuscript and the response letter in both directions:

- In the **manuscript**, revised passages are highlighted and annotated in the margin with the IDs of the reviewer comments they address.
- In the **response letter**, each reply can automatically quote the revised text together with its section and page number, so that reviewers can verify the revision without leaving the letter.

The quotation is always taken from the current manuscript source, so it never goes stale when you keep editing the paper.

## Requirements

A reasonably recent TeX distribution. The package loads:
`xcolor`, `colortbl`, `xr` (v6.00+ recommended), `xstring`, `ulem`, `refcount`, `xspace`, `alphalph`, `marginnote`, and `clipboard`.
All of them ship with TeX Live.

## Quick start

Two documents share one directory: the manuscript (say `paper.tex`) and the response letter (say `rebuttal.tex`).
The file names are free; they only have to match the `\externaldocument` arguments below.
This repository contains both files as a working example.

**Manuscript preamble:**

```latex
\usepackage[paper]{revision}
\externaldocument{rebuttal}          % letter file name without .tex
\newclipboard{revision-clipboard}    % storage for quoted texts
```

**Letter preamble:**

```latex
\usepackage[letter]{revision}
\externaldocument{paper}             % manuscript file name without .tex
\openclipboard{revision-clipboard}
```

**Mark a revision in the manuscript** with a *revision ID* of your choice (here `1-1`):

```latex
\R{1-1}{The revised sentence, \M{with the changed part highlighted}, continues here.}
```

**Structure the letter and quote the revision:**

```latex
\Reviewer{1}
\section*{Dear Reviewer \#1}

\Comment                    % becomes Comment 1.1
The comment text pasted from the review report.

\Reply
Our answer. We revised the manuscript as follows:

\RQuote{1-1}                % quotes the revised text with section/page
```

The letter then shows the quoted passage in a box labeled `1.1a [Section 2, Page 3]`, and the manuscript shows a margin badge `1.1a` (colored per reviewer) next to the revised passage.

## Building

Cross-references and quotations flow through the `.aux` and clipboard files of *both* documents, so build them alternately until the output stabilizes (twice each is usually enough):

```sh
latexmk -pdf paper      # writes revision labels and quoted text
latexmk -pdf rebuttal   # reads them; writes comment IDs
latexmk -pdf paper      # picks up comment IDs for the margin badges
latexmk -pdf rebuttal   # final section/page numbers
```

Unresolved references appear as `X` badges or `??`; they disappear once the builds converge.

## Command reference

### Package options

| Option | Use in | Effect |
|---|---|---|
| `paper` (default) | manuscript | highlights changes, adds margin badges, records quotations |
| `letter` | response letter | enables the letter-side commands; change marks render as highlights |
| `cameraready` | manuscript | all marks disappear; deleted text is omitted |

Switching `paper` to `cameraready` is the only change needed after acceptance.

For a Japanese manuscript, add `ja` to both documents (`[paper,ja]`, `[letter,ja]`).
It is orthogonal to the three options above and does two things: it strikes deleted text out with `uline--` instead of `ulem`, and it translates the literals (`コメント 1.1`, `1.1 への回答`, `1 節, 1 ページ`).
The switch matters because `ulem` looks for spaces to break a line at, so a struck-out Japanese passage would run off the page instead of wrapping; `uline--` handles both scripts.
It is not loaded by default because it is not on CTAN (a copy is bundled here) and it redefines a great deal.
If you forget `ja` on a Japanese engine, the package says so in the log.

### Marking changes (manuscript)

| Command | Short form | Meaning | `paper` rendering |
|---|---|---|---|
| `\Modified{new}` | `\M` | added or modified text | blue |
| `\Added{new}` | `\A` | same as `\Modified` | blue |
| `\Deleted{old}` | `\D` | removed text | red, struck out |
| `\Removed{old}` | — | same as `\Deleted` | red, struck out |
| `\Replaced{old}{new}` | `\Rep` | replacement | struck-out old + blue new |

### Tagging revisions for the letter (manuscript)

| Command | Meaning |
|---|---|
| `\Revised{id}{text}` (`\R`) | tags *text* with a revision ID: adds the margin badge, records section/page, and stores the text for quotation |
| `\RM{id}{text}` | shorthand for `\Revised{id}{\Modified{text}}` |
| `\RevisedNoMark{id}{text}` | like `\Revised` but without badge or highlight — for passages you want to quote without drawing attention to them in the paper |

Revision IDs are free-form strings (e.g. `1-1`, `2-3b`); avoid LaTeX special characters.
A useful convention is `<reviewer>-<comment>[<sub>]`.

To show a before/after comparison in the letter, combine the two layers:

```latex
\R{1-2}{\Rep{the old wording}{the new wording}}
```

`\RQuote{1-2}` then quotes both the struck-out old text and the highlighted new text.

### Structuring the letter

| Command | Meaning |
|---|---|
| `\Reviewer{id}` | starts the section for reviewer *id* and resets comment numbering; *id* is a single character (`1`, `2`, `A`, `M`, ...) that also selects the badge color |
| `\Comment` | starts a reviewer comment, auto-numbered `<reviewer>.<n>` (styled italic gray) |
| `\Comment[5]` | same, with an explicit comment number |
| `\Reply` | ends the comment text and starts your answer |
| `\Note{who}{text}` | small note set off as an indented block, prefixed `[** who]` (e.g. for co-author remarks) |

Every `\Comment` **must** be closed by a `\Reply` (the pair forms a
TeX group).

### Referencing revisions from the letter

Each of these generates a *reference ID* — the current comment ID plus
a letter suffix (`1.1a`, `1.1b`, ..., continuing with `aa` after `z`)
— and attaches it to the given revision, so the manuscript's margin
badge lists exactly the comments that caused each change.

| Command | Meaning |
|---|---|
| `\RQuote{id}` | quote the revised text of *id* in a box, with its section and page number |
| `\RRef{id}` | print only the reference badge (no quotation) |
| `\RRef[full]{id}` | print the badge followed by the location, as `1.1a (Section 2, Page 3)` |
| `\RTouch{id}` | associate the comment with the revision without printing anything |

`\RRef[full]` suits a reply that points at a revision too long to quote.
An unknown option is ignored with a warning in the log, so a typo such as `\RRef[Full]{id}` does not silently drop the location.

### Copy and paste within one document

| Command | Meaning |
|---|---|
| `\RCopy{key}{text}` | typeset *text* and store it under *key* |
| `\RPaste{key}` | typeset the stored text again |

## Reviewer colors

Badges are colored by the **first character** of the reference ID.
Predefined: `Reviewer0`/`ReviewerM` (cyan), `Reviewer1`/`ReviewerA` (green), `Reviewer2`/`ReviewerB` (magenta), `Reviewer3`/`ReviewerC` (yellow), and `ReviewerX` (gray, also the fallback for undefined IDs).
For a fourth numbered reviewer, define the color yourself:

```latex
\definecolor{Reviewer4}{rgb}{1.0,0.9,0.8}
```

Undefined colors fall back to gray with a one-time warning in the log.

## Camera-ready and clean sources

- **PDF:** switch the package option to `cameraready`.
- **Sources** (when the publisher wants markup-free `.tex` files): run the bundled script, which strips the revision commands while keeping their content:

  ```sh
  ruby detex.rb paper.tex > paper-clean.tex
  ```

  The script yields the same text as the `cameraready` option does, at any nesting depth.
  It is regex-based rather than a TeX parser, though, so skim the output if the source does anything unusual with braces or verbatim text.
  Note that `\Note` annotations are stripped by neither the script nor `cameraready`.

## Tips and caveats

- **Margins:** the package sets `\marginparwidth` to 2 cm for the badges.
  Two-column or narrow-margin journal styles may need manual adjustment of `\marginparwidth`/`\marginparsep`, and badge placement can interact with floats.
- **Paragraph breaks:** `\Revised` across several paragraphs is fragile; wrap each paragraph separately (`\R{3-1a}`, `\R{3-1b}`, ...) and quote them individually.
- **Floats:** marking inside `figure`/`table` environments may need case-by-case workarounds.
- **Custom commands inside quoted text:** the quoted passage is re-typeset in the letter, so every command it uses must be defined there too.
  Either define them in the letter as well (`\newcommand{\tabref}[1]{Table~\ref{#1}}` etc.), or move shared definitions into a common file `\input` by both documents.
- **Citations in the letter:** with xr v6.00 (TeX Live 2025+), `\externaldocument{paper}` also imports the manuscript's bibliography entries, so `\cite` works in the letter out of the box.
- **Overleaf:** use `\myexternaldocument{...}` instead of `\externaldocument{...}`; it additionally registers the other document's `.tex`/`.aux` files as dependencies so that Overleaf recompiles when they change.

## Repository contents

| File | Role |
|---|---|
| `revision.sty` | the package |
| `paper.tex`, `rebuttal.tex` | minimal working example (also used for testing) |
| `paper-ja.tex`, `rebuttal-ja.tex` | the same in Japanese, for the `ja` option (build with `platex`) |
| `uline--.sty` | bundled dependency of the `ja` option (not on CTAN) |
| `detex.rb` | strips revision markup from sources |
