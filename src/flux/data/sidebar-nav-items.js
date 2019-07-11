export default function() {
  return [
    {
      title: "Dashboard",
      to: "/Dashboard",
      text:"/Dashboard",
      htmlBefore: '<i class="material-icons">edit</i>',
      htmlAfter: ""
    },
    {
      title: "POS",
      htmlBefore: '<i class="material-icons">vertical_split</i>',
      to: "/pos-home",
      text:"/pos-home"
    },
    // {
    //   title: "POS",
    //   htmlBefore: '<i class="material-icons">note_add</i>',
    //   to: "/add-new-sales",
    // },
    // {
    //   title: "Forms & Components",
    //   htmlBefore: '<i class="material-icons">view_module</i>',
    //   to: "/components-overview",
    // },
    // {
    //   title: "Tables",
    //   htmlBefore: '<i class="material-icons">table_chart</i>',
    //   to: "/tables",
    // },
    // {
    //   title: "User Profile",
    //   htmlBefore: '<i class="material-icons">person</i>',
    //   to: "/user-profile-lite",
    // },
    // {
    //   title: "Errors",
    //   htmlBefore: '<i class="material-icons">error</i>',
    //   to: "/errors",
    // }
  ];
}
