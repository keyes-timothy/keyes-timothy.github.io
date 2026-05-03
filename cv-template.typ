// Minimal CV template — page numbers + heading rules only

// Page numbers
#set page(
  footer: context [
    #set align(center)
    #set text(8pt, fill: luma(120))
    Page #counter(page).display("1") of #counter(page).final().at(0)
  ],
)

// Section headings: thin rule beneath, tighter spacing
#show heading.where(level: 2): it => {
  v(0.5em)
  it
  v(0.1em)
  line(length: 100%, stroke: 0.4pt + luma(200))
  v(0.15em)
}

// Tighter list spacing
#set list(spacing: 0.4em)