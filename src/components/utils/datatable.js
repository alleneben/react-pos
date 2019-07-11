import React, { useState } from 'react';
import { Link } from 'react-router-dom';

import * as s from "../../shardslib";
import styles from '../../pagination.css';



function DataTable ({cfg,data,isSearch,printfn,transferfn, viewform,editform,addItem,searchdb, tbname,placeholder,btns,props,pager,pagerchanger,pos,plm,cnt,cnts}) {
  const [search, setsearch] = useState('');
  const [filtereditems, setfiltereditems] = useState(data);
  const [tbdata, settbdata] = useState(data);
  const [pglm, setpglm] = useState(10)


  const triggerFn = (fn,item) => {
    switch (fn) {
      case 'addfn':
        addItem(item);
        break;
      case 'viewfn':
        viewform(item,'viewfn','animated slideInUp')
        break;
      case 'editfn':
        editform(item,'editfn','animated slideInDown')
        break;
      case 'printfn':
        printfn(item,'pdf')
        break;
      case 'transferfn':
        transferfn(item)
        break;
      default:
        console.log('fxn not found');
    }
	}


  const onChange = (e) => {
    setsearch(e.target.value);
    settbdata(filtereditems.filter(item => new RegExp(e.target.value, "i").exec(item.nam)))
  }
  const searchfn = () => {
    searchdb(search,tbname)
  }
  const rightpagination = (pos,plm) => {
    pager(parseInt(pos)+parseInt(plm),plm,1)
  }
  const leftpagination = (pos,plm) => {
    pager(pos-plm,plm,-1)
  }
  const onchangepager = (e) => {
    setpglm(e.target.value)
    pagerchanger(0,e.target.value,1)
  }

  return (
    <div className="table-responsive">
    {isSearch && <> <s.InputGroup seamless className="mb-3">
       <s.FormInput placeholder={placeholder} value={search} onChange={onChange}/>
      <s.InputGroupAddon type="append">
      <s.InputGroupText>
        <i className="material-icons">search</i>
      </s.InputGroupText>
      <s.Button
        color="link"
        id="tooltip636901683"
        title=""
        type="button"
        onClick={searchfn}

      >
        Search
      </s.Button>
      </s.InputGroupAddon>
    </s.InputGroup> </>}
      <table className="table mb-0 tbody table-striped table-hover table-sm">
        <thead className="thead-light">
          <tr>
            {
              cfg.header.map((d,k) => {
                return (
                  <th key={k}>
                  { d }
                  </th>
                )
              })
            }
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <tr></tr>
          {
            tbdata.map((item,key) => {
              return (
                <tr key={key} >
                  {/*<td>{key+1}</td>*/}
                    {
                        cfg.flds.map((dd,kk) => {
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
      {isSearch && <><div className="pagination">
        <span onClick={() => leftpagination(pos,plm)}>&laquo;</span>
        <span onClick={() => rightpagination(pos,plm)}>&raquo;</span>
        <span>{cnt + '/' + cnts}</span>
        <s.FormSelect
          size="sm"
          value={plm}
          style={{ maxWidth: "130px" }}
          onChange={onchangepager}
        >
          <option value="10">10</option>
          <option value="20">20</option>
          <option value="30">30</option>
          <option value="40">40</option>
          <option value="50">50</option>
        </s.FormSelect>
      </div> </>}
    </div>
  )
}

export default DataTable;
