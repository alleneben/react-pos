import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';


import * as s from "../../shardslib";
import * as c from "../";
import styles from '../../pagination.css';
import api from '../../appstate/api'



let newdata=[]
function MagsterDataTable ({load,ttl,isShow,height,phld,btns,data,svc,a,tbcfg,p,dbf,prm,plm,printfn,addfn}) {
  const [loading, setloading] = useState(false);
  const [search, setsearch] = useState('');
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
    if(load) request(svc,a,'','',1,false,false,prm);

    return () => {
      console.log('bye');
    };
  },[])

  newdata = data.length < 1 ? tdata : data;

  const request = async (s,a,o,l,sign,chg,dsbl,param) => {
    setloading(true);setntf(false);setmsg(null);setplc(null)
    var fm = new FormData();
    console.log(param);
    if(param){
      fm.append(param.fld,param.val)
    }

    fm.append('s', svc);fm.append('nam',search);fm.append('a', a);fm.append('df','sp_'+dbf+'_find');
    fm.append("ssi", 'nggcf66ocm6om1hek81kejkluc');fm.append("uid", "3");
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
    setsearch(e.target.value);
    settdata(filtereditems.filter(item => new RegExp(e.target.value, "i").exec(item.nam)))
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
      case 'printfn':
        printfn(item,'pdf')
        break;
      case 'transferfn':
        // transferfn(item)
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
        {isShow && <s.InputGroup seamless className="mb-3">
          <s.FormInput placeholder={'Search '+phld} value={search} onChange={onChange}/>
          <s.InputGroupAddon type="append">
          <s.InputGroupText>
            <i className="material-icons">search</i>
          </s.InputGroupText>
          <s.Button
            disabled={!search}
            theme="primary"
            type="button"
            onClick={() => request(svc,a,cnt,pglm,1,false,false,5)}
          >
            Search
          </s.Button>
        { /* <s.Button
            theme="white"
            onClick={() => request(svc,a,cnt,'',1,false,false,5)}
          >
            <span className="text-success"><i className="material-icons">refresh</i></span>{" "} Load All
          </s.Button>*/}
          </s.InputGroupAddon>
        </s.InputGroup>}
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

                              {/*<s.Button theme="white" onClick={() => viewfn(item)}>
                                <span className="text-success">
                                  <i className="material-icons">check</i>
                                </span>{" "}
                                View
                              </s.Button>
                              <s.Button theme="white" onClick={() => editfn(item)}>
                                <span className="text-danger">
                                  <i className="material-icons">more_vert</i>
                                </span>{" "}
                                Incidents
                              </s.Button>*/}
                              {/*<s.Button theme="white" onClick={() => editfn(item)}>
                                <span className="text-primary">
                                  <i className="material-icons">more_vert</i>
                                </span>{" "}
                                Edit
                              </s.Button>*/}
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
