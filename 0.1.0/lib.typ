#import "/layout/titlepage.typ": *
#import "/layout/disclaimer.typ": *
#import "/layout/acknowledgement.typ": acknowledgement as acknowledgement_layout
#import "/layout/abstract.typ": *
#import "/utils/print_page_break.typ": *
#import "/layout/fonts.typ": *
#import "@preview/glossarium:0.5.4": make-glossary, register-glossary, print-glossary, gls, glspl
#import "@preview/acrostiche:0.5.1": *
 #import "@preview/abbr:0.2.3"

#let thesis(
  titleGerman: "",
  submissionDate: "",
  professor: "",
  professorship: "",
  title: "",
  degree: "",
  faculty: "",
  author: "",
  supervisor: "",
  abstract_en: "",
  abstract_de: "",
  is_print: false,
  body,
) = {

  titlepage(
    title: title,
    degree: degree,
    author: author,
    supervisor: supervisor,
    submissionDate: submissionDate,
    professorship: professorship,
    professor: professor,
    faculty: faculty,
  )

  print_page_break(print: is_print)
  print_page_break(print: is_print)

  disclaimer(
    title: title,
    degree: degree,
    author: author,
    submissionDate: submissionDate,
  )

  print_page_break(print: is_print)


  print_page_break(print: is_print)

  abstract(lang: "en")[#abstract_en]
  print_page_break(print: is_print)
  print_page_break(print: is_print)

  set page(
    margin: (left: 30mm, right: 30mm, top: 60mm, bottom: 40mm),
    numbering: none,
    number-align: center,
  )

  set text(
    font: fonts.body,
    size: 11pt,
    lang: "en"
  )

  show math.equation: set text(weight: 400)

  // --- Headings ---
  show heading: set block(below: 2.1em, above: 1.75em)
  show heading: set text(font: fonts.body,  1.6em, weight: "semibold")
  show: make-glossary

  set heading(numbering: "1.1")
  // Reference first-level headings as "chapters"
  show ref: it => {
    let el = it.element
    if el != none and el.func() == heading and el.level == 2 {
      link(
        el.location(),
        [Chapter #numbering(
          el.numbering,
          ..counter(heading).at(el.location())
        )]
      )
    } else {
      it
    }
  }

  // --- Paragraphs ---
  set par(leading: 1em)

  // --- Citations ---
  set cite(style: "alphanumeric")

  // --- Figures ---
  show figure: set text(size: 0.85em)

  // --- Table of Contents ---
  show outline.entry.where(level: 1): it => {
    v(15pt, weak: true)
    strong(it)
  }

  outline(
    title: {
      text(font: fonts.body, "Contents")
      v(15mm)
    },
    indent: 2em
  )


  v(2.4fr)
  pagebreak()
  pagebreak()

    outline(
    title: {
      text(font: fonts.body, "List of Figures")
            v(15mm)

    }, target: figure.where(kind: image))

  pagebreak()

  pagebreak()

    outline(
    title: {
      text(font: fonts.body,  "List of Tables")
      v(15mm)

    }, target: figure.where(kind: table))

    pagebreak()
    pagebreak()





    // Main body. Reset page numbering.
  counter(page).update(1)
  set page(numbering: "1")
  set par(justify: true, first-line-indent: 2em)

  body
  pagebreak(to: "odd", weak: false)
    bibliography("/thesis.bib")
    
  pagebreak(to: "odd", weak: false)
  abbr.list(title:"Acronyms")


}