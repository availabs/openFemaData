import SectionDisplayComp from "./components/SectionDisplayComp"

// const pageElement = {
//   app: "meta",
//   type: "page-element",
//   attributes: [
//     {
//       key: "element-type",
//       type: "text"
//     },
//     {
//       key: "element-data",
//       type: "text"
//     }
//   ]
// }

const pageSection = {
  app: "hazard-methods",
  type: "page-section",
  // registerFormats: [pageElement],
  attributes: [
      { key: "title",
        type: "text"
      },
      {
        key: 'section',
        type: "text"
      },
      { key: "element",
        type: "type-select",
        attributes: [
          { key: "Draft Editor",
            type: "richtext"
          },
          { key: "Simple Text",
            type: "text"
          },
          { key: "Asset Table",
            type: "asset-table"
          }
        ]
      }

  ]
}

const metaDoc = {
  app: "hazard-methods",
  type: "doc-page",
  registerFormats: [pageSection],
  attributes: [
    { key: "section",
      type: "text",
      required: true,
      default: "props:section",
      hidden: true
    },
    { key: "sectionLanding",
      type: "boolean",
      default: false,
      editable: false,
      hidden: true
    },
    {
      key: "index",
      type: "number",
      default: "props:index",
      editable: false,
      hidden: true
    },
    { key: "title",
      type: "text"
    },
    {
      key: 'url-slug',
      type: "text"
    },
    {
      key: 'showSidebar',
      type: "boolean",
      default: true,
      required: true
    },
    {
      key: 'sections',
      type: "dms-format",
      format: "hazard-methods+page-section",
      isArray: true,
      useOrdered: true,
      showControls: false,
      DisplayComp: SectionDisplayComp
    }
  ]
}

export {
  metaDoc,
  pageSection,
  // pageElement
}
