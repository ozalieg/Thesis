#import "lib.typ": thesis
#import "metadata.typ": *
 #import "@preview/abbr:0.2.3"

#set document(title: "", author: "")
#show: thesis.with(
    title: titleEnglish,
    titleGerman: titleGerman,
    degree: degree,
    supervisor: supervisor,
    author: author,
    faculty: faculty,
    professorship: professorship,
    professor: professor,
    submissionDate: "2 June 2025",
    abstract_en: include "/content/abstract_en.typ",
    abstract_de: "",
)

#include "/content/introduction.typ"
#pagebreak()
#include "/content/chapter1.typ"
