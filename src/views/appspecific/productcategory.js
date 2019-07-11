import React, { useState, useContext, useEffect } from "react";
import * as s from "../../shardslib";
import * as c from '../../components'

import { AppContext } from '../../appstate/appcontext'
import utils from '../../appstate/utils';
import api from '../../appstate/api'
import * as cf from '../forms'

let cboc;
let cbou;
let cnts;

const ProductCategory = (props) => {
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
    setcontentmenu('categories')

    return () => {
      console.log('bye');
    };
  },[])



  const dismissfn = (param) => {
    setnotify(param)
  }

  const addfn = (dd) => {
    const {form} = dd;

    setnotify(null)
    setmsg(null)
    if(utils.utilfxns.validate(form)){
      setnotify(true)
      setmsg(utils.utilfxns.validate(form))
      setplace('tr')
      settheme('danger')
      console.log(utils.utilfxns.validate(form));
    } else {

      setloading(true)
      utils.utilfxns.submitdata(dd).then(rd => {
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
        setmsg('Failed to Add Category Data')
        setplace('tr')
        setloading(false)
        // dispatch({type:'ERROR_MSG', payload:err,error:true,loading:false,color:'danger'})
      })
    }
  }

  const editfn = (dd) => {
    const {form} = dd;
    if(utils.utilfxns.validate(form)){
      setnotify(true)
      setmsg(utils.utilfxns.validate(form))
      settheme('danger')
    } else {

      //dispatch({type:'LOAD_DATA',loading:true})
      setloading(true)
      utils.utilfxns.submitdata(dd).then(rd => {
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
          setloading(false)
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
    if (menus.text === 'Create') {
      switch (menus.cid) {
        case 'product':
          setcontentmenu(menus.cid)
          break;
        case 'categories':
          setcontentmenu(menus.cid)
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
        case 'products':
          setcontentmenu(menus.cid)
          break;
        default:
          break;
      }
    }
  }

  const mkpcusttbl = () =>{
    const tbcfg = {header:['S/No','Name'],flds:[{n:'nam',f:'t'}]}
    const p = '{"rid":"n","nam":"t","shc":"t","sts":"n","pos":"n","plm":"n"}'
    return <c.MagsterDataTable load={true} isShow={true} height='320px' phld='Categories' btns={[]} data={[]} tbcfg={tbcfg} svc='fd' a='find' p={p} dbf='categories'/>
  }


  const makesubmenus = () => {
    if (!!!state.auhmn.text) return;
    return <> {state.auhmn.smenus.map((mn,key) => <a key={key} className="menu-btn animated slideInLeft"  target="_blank" rel="noopener noreferrer" onClick={() => submenus(mn)}>{mn.text}</a>)} </>
  }

  const makecontent = (menu) => {
    if(menu === '') return;
    var content =  menu === 'categories' ?
                        <>
                        { makeaddform('categories') }<br/>
                        { mkpcusttbl() }
                        </> : ''
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
          { loading ? <><s.Spinner size={50} spinnerColor={"#333"} spinnerWidth={2} visible={loading} /></> : makecontent(contentmenu)  }
        </s.Col>
      </s.Row>
    </s.Container>
  );
}
export default ProductCategory;
