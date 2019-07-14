import React, { useState, useEffect, useReducer } from 'react';
import { Link } from 'react-router-dom';


import * as s from "../../shardslib";
import * as c from "../";
import RangeDatePicker from "./rangedatepicker";
import styles from '../../pagination.css';
import api from '../../appstate/api';
import utils from '../../appstate/utils'



let newdata=[]
function MagsterDataTable ({load,reload,ttl,isShow,height,phld,btns,data,svc,a,tbcfg,p,dbf,spm,plm,printfn,addfn}) {
  const [cstate, setState] = useReducer(
    (cstate, newState) => ({...cstate, ...newState}),
    { search: {}, }
    )
  const [loading, setloading] = useState(false);

  const [tdata, settdata] = useState([])
  const [filtereditems, setfiltereditems] = useState([]);
  const [datalen, setdatalen] = useState(0)
  const [cnts, setcnts] = useState(0)
  const [cnt, setcnt] = useState(0)
  const [pglm,setpglm] = useState(0)
  const [disable,setdisable] = useState(true)

  const [ntf, setntf] = useState(false);
  const [msg, setmsg] = useState('');
  const [plc, setplc] = useState('')

  useEffect(() => {
    if(load) request(svc,a,'','',1,true,false,spm);

    return () => {
      console.log('cleaning up ...');
    };
  },[reload])

  newdata = data.length < 1 ? tdata : data;

  const request = async (s,a,o,l,sign,chg,dsbl,param) => {
    setloading(true);setntf(false);setmsg(null);setplc(null);
    var fm = new FormData(),pps={};
    if(param){
      for (var key in param) {
        if(key === 'sdt' || key === 'edt'){
          var dt = param[key].toISOString();
          fm.append(key,dt);
        }else {
          fm.append(key,param[key]);
        }
        pps[key]= key.substr(key.length-1);
      }
    }

    fm.append('s', svc);fm.append('a', a);fm.append('df','sp_'+dbf+'_find');
    fm.append("ssi", 'nggcf66ocm6om1hek81kejkluc');fm.append("uid", "3");
    fm.append("ssi", utils.utilfxns.getcookie('_metalcraft'));fm.append("uid", utils.utilfxns.getuid());
    fm.append('m','l');fm.append('dd',p);fm.append('plm',l);fm.append('pos',o);

    var response = await fetch(api.fxns.endpoint,{method: 'post', body: fm})
    let data = await response.json();

    setloading(false)
    if(data.success){
      let tot = data.sd.length < 1 ? 0 : data.rc.rid;
      let dcnt =  chg ? sign * data.sd.length : cnt +  sign * data.sd.length;
      setcnts(tot);
      setcnt(dcnt)
      setdatalen(data.sd.length)
      settdata(data.sd)
      setfiltereditems(data.sd)
      setdisable(dsbl)
    } else {
      err(data[0].em,'tr',true)
    }
  }
  const err = (msg,plc,ntf) => {
    setntf(ntf)
    setmsg(msg);
    setplc(plc)
  }
  const onChange = (e) => {
    // setsearch({...search,[e.target.name]:e.target.value});
    setState({search: {...cstate.search, [e.target.name]:e.target.value}})

    settdata(filtereditems.filter(item => new RegExp(e.target.value, "i").exec(item.nam)))
  }

  const onStartChange = (value) =>{
    // setsearch({...search,['sdt']: value})
    setState({search: {...cstate.search, ['sdt']: value}})
  }
  const onEndChange = (value) =>{
    // setsearch({...search,['edt']: value})
    setState({search: {...cstate.search, ['edt']: value}})
  }
  const clearfilters = () => {
    // setsearch({})
    setState({search: {}})
  }
  const rightpagination = () => {
    return cnt === parseInt(cnts) ? false : request(svc,a,cnt,pglm,1,false,true,5)
  }
  const leftpagination = () => {
    let len = cnt === parseInt(cnts) ? parseInt(cnts) - datalen : cnt-2*parseInt(pglm);
    return cnt <= parseInt(pglm) ? false : request(svc,a,len,pglm,-1,false,true,5)
  }
  const onchangepager = (e) => {
    setpglm(e.target.value)
    request(svc,a,0,e.target.value,1,true,true,5)
  }

  const download = (item,p,svc,a,dbf,fmt) => {
    let sp = typeof item === 'object' ? {rid:item.rid} : cstate.search;
    utils.utilfxns.download(sp,p,svc,a,dbf,fmt)
    .then(rd => {
      rd[0].then(file => {
        if(file.size > 100){
          utils.utilfxns.apipdf(file,rd[1],'pdf');
        }
      })
    })
  }


  const triggerFn = (fn,item) => {
    switch (fn) {
      case 'addfn':
        addfn(item);
        break;
      case 'viewfn':
        // viewform(item,'viewfn','animated slideInUp')
        break;
      case 'editfn':
        // editform(item,'editfn','animated slideInDown')
        break;
      case 'download':
        download(item,p,'rp','members','members','pdf')
        break;
      default:
        console.log('fxn not found');
    }
	}
  return (
    <>
    <c.CustomCard animated='animated fadeIn' title={ttl} children={
      <s.Row noGutters className="border-bottom py-2 bg-light">
        <div className="table-responsive">
        {isShow &&<> <s.InputGroup seamless className="mb-3">
          <s.FormInput placeholder={'Search '+phld} name="nam" value={cstate.search.nam || ''} onChange={onChange}/>
          <s.FormInput placeholder={'Search by Code'} name="sno" value={cstate.search.sno || ''} onChange={onChange}/>
          <s.InputGroupAddon type="append">
          <s.InputGroupText>
            <i className="material-icons">search</i>
          </s.InputGroupText>
          <s.Button
            disabled={!cstate.search}
            theme="primary"
            type="button"
            onClick={() => request(svc,a,'','',1,true,false,cstate.search)}
          >
            Search
          </s.Button>
          </s.InputGroupAddon>
        </s.InputGroup>
        <s.InputGroup seamless className="mb-3">
          <RangeDatePicker onStartChange={onStartChange} onEndChange={onEndChange} clearfilters={clearfilters}/>
          <s.InputGroupAddon type="append">
            <s.InputGroupText onClick={() => download('',p,svc,a,dbf,'fmt')} className="clearfilters">
              <i className="material-icons">print</i>
              <img src={require("../../assets/img/icons8-export-pdf-16.png")} style={{height:'20px',width:'20px'}} className="mr-2" alt="Shards - Agency Landing Page" />
            </s.InputGroupText>
            <s.InputGroupText onClick={() => download('',p,svc,a,dbf,'xls')} className="clearfilters">
              <i className="material-icons">print</i>
              <img src={require("../../assets/img/icons8-xls-48.png")} style={{height:'20px',width:'20px'}} className="mr-2" alt="Shards - Agency Landing Page" />
            </s.InputGroupText>
          </s.InputGroupAddon>
        </s.InputGroup></>}
        <div className="tbl" style={{ height: height}}>
          <table className="table mb-0 tbody table-striped table-hover table-sm">
            <thead className="thead-light">
              <tr>
                {
                  tbcfg.header.map((d,k) => {
                    return (
                      <th key={k}>
                      { d }
                      </th>
                    )
                  })
                }
              </tr>
            </thead>
            <tbody>
              <tr></tr>
              { loading ? <tr><td>loading</td></tr> :
                newdata.map((item,key) => {
                  return (
                    <tr key={key} >
                        <td>{key+1}</td>
                        {
                            tbcfg.flds.map((dd,kk) => {
                                var val = dd.f === 'd' ? parseFloat(item[dd.n]).toFixed(2) : item[dd.n];
                                return (
                                    <td key={kk}>{val}</td>
                                )
                            })
                        }
                        <td className="td-actions">
                          <div className="blog-comments__actions">
                            <s.ButtonGroup size="sm">
                            {
                              btns.map((b,k) => {
                                if (b.type == 'lnk') {
                                  return <Link key={k} to={{pathname:`${b.lnk+item.rid}`,data:item, id:item.rid}}>{ b.btn }</Link>
                                } else {
                                  return ( <div key={k} onClick={() => triggerFn(b.fn,item)}> { b.btn } </div> );
                                }
                              })
                            }
                            </s.ButtonGroup>
                          </div>
                      </td>
                    </tr>
                  );
                })
              }
            </tbody>
          </table>
        </div>
        { ntf && msg && plc && <c.Notification place={plc} type='danger' msg={msg} time='3'/>}
        </div>
      </s.Row>}

      footer= {isShow && <div className="pagination">
        {disable && <span onClick={() => leftpagination()}>&laquo;</span>}
        {disable && <span onClick={() => rightpagination()}>&raquo;</span> }
        <span>{ cnt + '/' + cnts}</span>
        <s.FormSelect
          size="sm"
          value={pglm}
          style={{ maxWidth: "100px" }}
          onChange={onchangepager}
        >
          <option value="0">No Data</option>
          <option value="10">10</option>
          <option value="20">20</option>
          <option value="30">30</option>
          <option value="40">40</option>
          <option value="50">50</option>
        </s.FormSelect>
      </div> }
    />
    </>
  )
}

export default MagsterDataTable;
