import React, { useState, useContext, useEffect } from "react";
import * as s from "../../shardslib";
import * as c from '../../components'

import { AppContext } from '../../appstate/appcontext'
import utils from '../../appstate/utils';
import * as cf from '../forms'

let cboc;
let cbou;
let cnts;

const Customers = (props) => {
  // forms
  const [view,setview] = useState(false);
  const [edit,setedit] = useState(false);
  // const [showaddform, setshowaddform] = useState(false);
  const [clearaddform, setclearaddform] = useState(false);
  const [formtype, setformtype] = useState('');

  // data
  const [extdata, setextdata] = useState([]);
  const [tbdata,settbdata] = useState([])
  const [pos, setpos] = useState(0);
  const [plm, setplm] = useState(10);
  const [cnt, setcnt] = useState(10);
  const [table, settable] = useState(false)

  // menu
  const [contentmenu,setcontentmenu] = useState('')

  // utilities
  const [notify, setnotify] = useState(null)
  const [msg, setmsg] = useState(null)
  const [place, setplace] = useState(null)
  const [theme, settheme] = useState('')
  const [loading, setloading] = useState(false);


  const { state, dispatch } = useContext(AppContext)

  utils.utilfxns.combo('sp_productcategories_combo','cidn').then(rd => {
    cboc=[]
    rd.sd.map(opt => {
      cboc.push({label:opt.nam,value:opt.rid,nam:'cidn'});
    })
  })
  utils.utilfxns.combo('sp_unit_combo','unin').then(rd => {
    cbou=[]
    rd.sd.map(opt => {
      cbou.push({label:opt.nam,value:opt.rid,nam:'unin'});
    })
  })

  useEffect(() => {
    setcontentmenu('customer')
    // setloading(true)
    // utils.utilfxns.fetchdata('','member',pos,plm).then(rd => {
    //   var out = rd;
    //   if (out.success) {
    //     settbdata(rd.sd)
    //     cnts = rd.rc.rid;
    //     setcnt(rd.sd.length)
    //     setloading(false)
    //     setcontentmenu('customer')
    //   } else {
    //     setnotify(true)
    //     settheme('danger')
    //     setmsg(out[0].em)
    //     setplace('tr')
    //     setloading(false)
    //   }
    //
    // },err => {
    //   setnotify(true)
    //   settheme('danger')
    //   setmsg('Failed to Fetch Asset Data')
    //   setplace('tr')
    //   setloading(false)
    // })

    return () => {
      console.log('bye');
    };
  },[])



  const dismissfn = (param) => {
    setnotify(param)
  }

  const addfn = (fm) => {
    const {form} = fm;

    setnotify(null)
    setmsg(null)
    setplace(null)
    if(utils.utilfxns.validate(form)){
      setnotify(true)
      setmsg(utils.utilfxns.validate(form))
      setplace('tr')
    } else {

      setloading(true)
      utils.utilfxns.submitdata(fm).then(rd => {
        var out = rd;
        if(out.success){
          setloading(false)
          // settbdata(out.sd)
          setnotify(true)
          settheme('success')
          setmsg(out.sd[0]['nam']+' was added successfully')
          setplace('tr')
          //clearform()
          // setshowaddform((prev) => !prev)
        } else {
          setnotify(true)
          settheme('danger')
          setmsg(out[0].em)
          setplace('tr')
          setloading(false)
          // dispatch({type:'ERROR_MSG', payload:out.em,error:true,loading:false,color:'danger'})
        }
      },err => {
        setnotify(true)
        settheme('danger')
        setmsg('Failed to Fetch Data')
        setplace('tr')
        setloading(false)
        // dispatch({type:'ERROR_MSG', payload:err,error:true,loading:false,color:'danger'})
      })
    }
  }

  const editfn = (dd) => {
    const {form} = dd;
    setnotify(null)
    setmsg(null)
    setplace(null)
    if(utils.utilfxns.validate(form)){
      setnotify(true)
      setmsg(utils.utilfxns.validate(form))
      setplace('tr')
    } else {

      //dispatch({type:'LOAD_DATA',loading:true})
      setloading(true)
      utils.utilfxns.submitdata(dd).then(rd => {
        setloading(false)
        var out = rd;
        if(out.success){
          setloading(false)
          // settbdata(out.sd)
          setnotify(true)
          settheme('success')
          setmsg(out.sd[0]['nam']+' was update successfully')
          setplace('tr')
          setedit(false)

          //dispatch({type:'LOAD_DATA', loading:false, payload:rd.sd})
        } else {
          setnotify(true)
          settheme('danger')
          setmsg(out.em)
          setplace('tr')

          // dispatch({type:'ERROR_MSG', payload:out.em,error:true,loading:false,color:'danger'})
        }
      },err => {
        setnotify(true)
        settheme('danger')
        setmsg('Failed to Fetch Asset Data')
        setloading(false)
        // dispatch({type:'ERROR_MSG', payload:err,error:true,loading:false,color:'danger'})
      })
    }
  }

  const submenus = (menus) => {
    setloading(true);
    if (menus.text === 'Create') {
      switch (menus.cid) {
        case 'customer':
          setloading(false)
          setcontentmenu(menus.cid)
          break;
        case 'categories':
          setloading(false)
          break;
        default:
          console.log('pass');
          break;
      }

    } else {
      switch (menus.cid) {
        case 'sales':
          setcontentmenu(menus.cid)
          break;
        case 'customers':
          setloading(false)
          setcontentmenu(menus.cid)
          break;
        default:
          break;
      }
    }
  }
  const mkpcusttbl = () =>{
    const btns = [
      {btn:<s.Button theme="white"><span className="text-success"><i className="material-icons">more_vert</i></span>{" "} Detail </s.Button>,fn:'viewfn',type:'lnk',lnk:'/customers/'},
      {btn:<s.Button theme="white"><span className="text-primary"><i className="material-icons">check</i></span>{" "} Edit </s.Button>,fn:'editfn',type:'btn'},
      {btn:<s.Button theme="white"><span className="text-danger"><i className="material-icons">print</i></span>{" "} Print </s.Button>,fn:'download',type:'btn'},
    ]
    const tbcfg = {header:['S/No','Name','Code','Mob 1','Mob 2','Actions'],flds:[{n:'nam',f:'t'},{n:'mno',f:'t'},{n:'mob',f:'t'},{n:'tel',f:'t'}]}
    const p = '{"rid":"n","nam":"t","cod":"t","sdt":"t","edt":"t","sts":"n","pos":"n","plm":"n"}'
    return <c.MagsterDataTable load={true} isShow={true} height='320px' phld='Customers' btns={btns} data={[]} tbcfg={tbcfg} svc='fd' a='find' p={p} dbf='member'/>
  }

  const makesubmenus = () => {
    if (!!!state.auhmn.text) return;
    return <> {state.auhmn.smenus.map((mn,key) => <a key={key} className="menu-btn animated slideInLeft"  target="_blank" rel="noopener noreferrer" onClick={() => submenus(mn)}>{mn.text}</a>)} </>
  }
  const makecontent = (menu) => {
    if(menu === '') return;
    var content = menu === 'customers' ?
                    mkpcusttbl(menu)   :
                  menu === 'customer'  ?
                    makeaddform('customer') :
                    mkpcusttbl(menu)
    return content
  }

  const viewform = (item,type) => {
    setview(true)
    setextdata(item)
    setformtype(type)
  }

  const closeviewform = () => {
    setview(false)
  }

  const editform = (item,type) => {
    setedit(true)
    setextdata(item)
    setformtype(type)
  }

  const closeeditform = () => {
    setedit(false)
  }

  // const addform = (param) => {
  //   setformtype(param)
  //   setshowaddform(true)
  // }

  // const closeaddform = () => {
  //   setshowaddform((prev) => !prev)
  // }

  const clearform = () => {
    setclearaddform(true)
  }

  const errormsg = (msg) => {
    setnotify(null)
    setmsg(null)

    var errmsg = msg+' ' + 'is Required';
    setmsg(errmsg)
    setnotify(true)
    settheme('danger')
  }


  const makeext = (item,type,animate) => {
    var flds={ridn:item.rid,namt:item.nam,bprn:item.bpr,prcn:item.prc,rsbn:item.rsb,wrsbn:item.wrsb,qtyn:item.qty,qpbn:item.qpb,cidn:item.cid,unin:item.uni,dsct:item.dsc}
    var t = type === 'editfn' ?
    <cf.EditForm item={item} submit={editfn} fmtype='edit product' closeeditform={closeeditform} cboc={cboc} cbou={cbou} flds={flds}/> :
    <cf.ViewForm item={item} closeviewform={closeviewform}/>;
    // if(state.data === undefined) return <>fetching incidents.... <c.Notification theme='danger' msg='Slow Connection' time='7'/></>
    return <c.PlainCard animated={animate} children={t} />
  }



  const makeaddform = (param) => {
    return <cf.AddForm submit={addfn} fmtype={param} closeaddform='' clearaddform={clearform} animated='animated fadeIn p-3' cboc={cboc} cbou={cbou}/>;
  }

  return (
    <s.Container fluid className="main-content-container px-4 pb-4 pt-4">
      <s.Row>
      <div className="menu-container">{ makesubmenus() }</div>
        <s.Col lg="12" md="12">
          { notify && msg && place && <c.Notification place={place} type='danger' msg={msg} time='3'/>}
          { view ? makeext(extdata,formtype,'animated fadeIn') : edit ? makeext(extdata,formtype,'animated fadeIn') : '' }
          { /*formtype && showaddform && makeaddform(formtype)*/ } <br/>
          { makecontent(contentmenu)  }
        </s.Col>
      </s.Row>
    </s.Container>
  );
}
export default Customers;
