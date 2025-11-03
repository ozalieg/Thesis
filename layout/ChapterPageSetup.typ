#let chapter_title_page = set page(
  margin: (top: 60mm, bottom: 40mm, left: 30mm, right: 30mm),
  numbering: "arabic",
  number-align: center,
)

#let chapter_regular_page = set page(
  margin: (top: 40mm, bottom: 40mm, left: 30mm, right: 30mm),
  numbering: "arabic",
  number-align: center,
)

#let chapter(title, body) = {
  _ = {
    chapter_title_page
    heading[title]
    body
    chapter_regular_page
  }
}
