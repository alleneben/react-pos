
export default function(state,action){
  // console.log({state,action});
    switch(action.type){
      case 'CHECK_CONNECTION':
        return {
          ...state,
          loading: action.loading
        }
        case 'LOADING':
          return {
            ...state,
            initloading: action.initloading
          }
        case 'LOAD_TABLE':
          return {
            ...state,
            loading: action.loading,
            data: action.payload,
            contentmenu: action.contentmenu
          }
        case 'SEARCH_TABLE':
          return {
            ...state,
            data: action.payload
          }
        case 'SELECT':
          return {
            ...state,
            selected: action.payload,
            viewmodalstate:action.viewmodalstate
          }
        case 'UNSELECT':
          return {
            ...state,
            viewmodalstate: action.viewmodalstate
          }
        case 'DATA_SUBMIT':
          return {
            ...state,
            loading: action.loading
          }
        case 'MODAL_CLOSE':
          return {
            ...state,
            modalState:action.action
          }
        case 'USER_LOGGED_IN':
          return {
            ...state,
            menu: action.payload,
            initloading: action.initloading
          }
        case 'DASHBOARD_MENUS':
          return {
            ...state,
            menu: action.payload,
            loading: false
          }
        case 'SUB_MENUS':
          return {
            ...state,
            auhmn: action.payload
          }
        case 'LOAD_CATEGORY_COMBO':
          return {
            ...state,
            categorycombo: action.payload
          }
        case 'LOAD_MODEACQUIRED_COMBO':
          return {
            ...state,
            modeacquiredcombo: action.payload
          }
        case 'LOAD_ASSETSTATUS_COMBO':
          return {
            ...state,
            assetstatuscombo: action.payload
          }
        case 'LOAD_DEPARTMENT_COMBO':
          return {
            ...state,
            departmentcombo: action.payload
          }
        case 'LOAD_LOCATION_COMBO':
          return {
            ...state,
            locationcombo: action.payload
          }
        case 'LOAD_SUPPLIER_COMBO':
          return {
            ...state,
            suppliercombo: action.payload
          }
        case 'EDIT_DATA':
          return {
            ...state,
            editdata: action.payload,
            showedit: action.showedit
          }
        case 'CLOSE_FORM':
          return {
            ...state,
            showform: action.showform
          }
        case 'LOAD_DATA':
          return {
            ...state,
            loading: action.loading,
            data: action.payload
          }
        case 'LOAD_SUBMENUS':
          return {
            ...state,
            loading: action.loading,
            smnu: action.payload
          }
        case 'USER_LOGGED_OUT':
          return {
            ...state,
            initloading: action.initloading
          }
        case 'PRINT_REPORT':
          return {
            ...state,
            printreport: action.payload
          }
        default:
            return state;
    }
}
