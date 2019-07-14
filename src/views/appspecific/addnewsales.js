import React, { useState,useContext,useEffect } from "react";
import * as s from "../../shardslib";
import * as c from '../../components';


import { AppContext } from '../../appstate/appcontext'
import utils from '../../appstate/utils';


// let n=0;
let deckitemkeys = [];
let subtotal;
let cnts;

const AddNewSales = () => {
  const [search, setsearch] = useState('');
  const [val, setvalue]=useState({codt:'',amtn:'',ptin:'',disn:''});

  const [selecteditem,setselecteditem] = useState(null);
  const [deckitems,setdeckitems] = useState([]);
  const [nqy,setnqy] = useState(1);
  const [discount, setdiscount] = useState(0);
  const [grandtotal, setgrandtotal] = useState(0);

  const [extdata, setextdata] = useState([]);
  const [ext,setext] = useState(false);
  const [tbdata,settbdata] = useState([])
  const [pos, setpos] = useState(0);
  const [plm, setplm] = useState(10);
  const [cnt, setcnt] = useState(10);
  const [reload, setreload] = useState(false)


  // menu
  const [contentmenu,setcontentmenu] = useState('')

  // utilities
  const [notify, setnotify] = useState(null)
  const [msg, setmsg] = useState(null)
  const [place, setplace] = useState(null)
  const [theme, settheme] = useState('')
  const [loading, setloading] = useState(false);
  const [open, setopen] = useState(false)

  const [rdv,setrdv] = useState([]);
  const { state, dispatch,props } = useContext(AppContext)


  useEffect(() => {

    return () => {
      console.log('bye');
      deckitemkeys = []
    };
  },[])

  const onSetVal = (e) =>{
     setvalue({...val, ptin: e})
   }
  const onTextChange = (e)=>  setvalue({...val, [e.target.name]: e.target.value})
  const onChange = (e) => {
    //debugger
    setsearch(e.target.value);
  }

  const groupBy = (xs, key) => {
    if(xs === undefined) return ;
    return xs.reduce(function(rv, x) {
      (rv[x[key]] = rv[x[key]] || []).push(x);
      return rv;
    }, {});
  }
  const mapreduce = (xs,key) => {
    if(xs === undefined) return ;
    return xs.reduce(function(rv, x) {

      return rv[x[key]] =rv[x[key]] || []
    },{});
  }
  const addfn = (item) => {

    if(deckitemkeys.includes(item.rid)){
      console.log('item already exist')

      item['nqy'] = parseInt(item['nqy']) + 1
      setnqy(item['nqy'])
    } else {
      setselecteditem(deckitems.push(item))
      deckitemkeys.push(item.rid)
    }
  }

  const increase = (item) => {
    item['nqy'] = parseInt(item['nqy']) + 1
    setnqy(item['nqy'])
  }
  const decrease = (item) => {
    item['nqy'] = parseInt(item['nqy']) - 1;
    item['nqy'] = item['nqy'] == 0 ? 1 : item['nqy'];

    setnqy(item['nqy'])
  }
  const deleteitem = (item) => {
    item['nqy'] = 1;
    var idx = deckitems.indexOf(item);

    if (idx > -1) {
      deckitemkeys.splice(idx, 1)
      setselecteditem(deckitems.splice(idx, 1))
    }
  }
  const chooseprice = (price,item,type) => {
    // var idx = deckitems.indexOf(item);
    item['sprc']=price;
    item['pty']=type;
    setnqy(item['sprc'])

  }

  const showmodal = (items) => {
    setopen((prev) => !prev)
  }

  const dismissfn = (param) => {
    setnotify(param)
  }

  const closemodal = () => {
    setopen(false);
  }

  const submit = (items) => {
    setopen(false);setreload(false)
    if(items.length < 1) return ;

    setnotify(null)
    setmsg(null)
    setloading(true)
    utils.utilfxns.sales({items:items,f:'sp_sales_add_web',s:'ad',a:'add',fp:'{"cod":"t","amt":"n","pti":"n"}',val:val})
    .then(rd => {
      setloading(false)
      rd[0].then(file => {
        if(file.size > 100){
          setloading(false)
          // settbdata(out.sd)
          setreload(true)
          setnotify(true)
          settheme('success')
          setmsg('Transaction was successfully')
          setplace('tr')
          setdeckitems([])
          deckitemkeys=[]
          utils.utilfxns.apipdf(file,rd[1],'pdf');
        }
        else {
          setnotify(true)
          settheme('danger')
          setmsg('failed')
          setplace('tr')
          setloading(false)
        }
      });
    },err => {
      setnotify(true)
      settheme('danger')
      setmsg('Failed to Fetch Asset Data')
      setplace('tr')
      setloading(false)
      // dispatch({type:'ERROR_MSG', payload:err,error:true,loading:false,color:'danger'})
    })
  }

  const makecategories = () => {
    return rdv.map((cat,key) => {
      return <a key={key} className="menu-btn animated slideInLeft"  target="_blank" rel="noopener noreferrer">{cat.nam}</a>
    });
  }
  const makedeckitems = (items) => {
    subtotal = 0.00;
    return items.map((item,key) => {
      subtotal = subtotal + (item.sprc * item.nqy)
      return <tr key={key} className="animated lightSpeedIn">
        <td>{ item.nam } 1 at { (item.sprc * 1).toFixed(2) }/{ item.ush }</td>
        <td><div className="qty"><div className="increase" onClick={()=>increase(item)}>+</div><div className="quantity"> {item.nqy}</div> <div className="decrease" onClick={()=>decrease(item)}>-</div></div></td>
        <td>{(item.sprc * item.nqy).toFixed(2) }</td>
        <td onClick={()=>chooseprice(item.prc,item,'prc')}>{ (item.prc * 1).toFixed(2) }</td>
        <td onClick={()=>chooseprice(item.rsb,item, 'rsb')}>{ (item.rsb * 1).toFixed(2) }</td>
        <td onClick={()=>chooseprice(item.wrsb,item, 'wrsb')}>{ (item.wrsb * 1).toFixed(2)}</td>
        <td onClick={()=>deleteitem(item)}><i className="material-icons">delete</i></td>
      </tr>
    });
  }

  const makecontent = (menu) => {
    if(menu === undefined) return;
    return mkpostbl()
  }

  const extendedview = (item) => {
    setext(true)
    setextdata(item)
  }
  const mkpostbl = () =>{
    const btns = [
      {btn:<s.Button theme="white"> Add </s.Button>,fn:'addfn',type:'btn'},
    ]
    const tbcfg = {header:['S/No','Item','Price','Qty', 'TQty','Actions'],flds:[{n:'nam',f:'t'},{n:'prc',f:'d'},{n:'qty',f:'n'},{n:'blk',f:'n'}]}
    const p = '{"rid":"n","nam":"t","sno":"t","sdt":"t","edt":"t","shi":"n","sts":"n","pos":"n","plm":"n"}'
    return <c.MagsterDataTable load={true} reload={reload} isShow={true} height='800px' phld='Items' btns={btns} data={[]} tbcfg={tbcfg} svc='fd' a='find' p={p} dbf='products' addfn={addfn}/>
  }
  return (
    <s.Container fluid className="main-content-container px-4 pb-4 pt-4">
    { msg && notify && place && <c.Notification place={place} type='danger' msg={msg} time='3'/>}
      <s.Row>
        <s.Col lg="6" md="12">
          { makecontent(contentmenu) }
        </s.Col>

        {/* Sidebar Widgets */}
        <s.Col lg="6" md="12">
          <c.PlainCard animated="animated rollIn" children={
            <div className="pos">
              <div className="deck">
                <table className="table mb-0 tbody">
                  <thead className="bg-light">
                    <tr>
                      <th scope="col" className="border-0">
                        Item
                      </th>
                      <th scope="col" className="border-0">
                        Qty
                      </th>
                      <th scope="col" className="border-0">
                        Total
                      </th>
                      <th scope="col" className="border-0">
                        RP1
                      </th>
                      <th scope="col" className="border-0">
                        RP2
                      </th>
                      <th scope="col" className="border-0">
                        WP
                      </th>
                    </tr>
                  </thead>
                  <tbody>
                    {
                      makedeckitems(deckitems)
                    }
                  </tbody>
                </table>
              </div>
              <div className="divider"></div>
              <div className="calc">
                <c.InputField id="RetailSalePrice2" md="6" label="" placeholder="Discount" type='number' name="disn" value={val.disn || ''} onChange={onTextChange}/>
                <h5>Total: GHC {val.disn ? (subtotal-val.disn).toFixed(2) : (subtotal).toFixed(2)}</h5><br/>
                <p>
                { subtotal ?
                      <s.Button theme="primary" className="btn-block animate lightSpeedIn" onClick={showmodal}><span className="text-white"><i className="material-icons">money</i></span>{" "} $$$ Make Sales </s.Button>
                      : ''
                }
                </p>
              </div>
            </div>
          }/>
          <c.CustomModal
            title="Payments"
            open={open}
            submit={submit}
            closemodal={closemodal}
            children={
              <>
              <div className="calc">
                Subtotal:{subtotal.toFixed(2)}<br/><hr/>
                Discount:{val.disn ? (val.disn * 1).toFixed(2) : (0.00).toFixed(2)}<br/><hr/>
                <h5>Total: GHC {(subtotal - val.disn).toFixed(2)}</h5><br/>
              </div>
              <s.Row form>
                <c.InputField id="RetailSalePrice2" md="6" label="" placeholder="Code" type='number' name="codt" value={val.codt || ''} onChange={onTextChange}/>
                <c.InputField id="RetailSalePrice2" md="6" label="" placeholder="Amount Recieved" type='number' name="amtn" value={val.amtn || ''} onChange={onTextChange}/>
                <c.CustomRadio md="3" label="Credit" name="ptin" checked={val.ptin === 1} onChange={() => onSetVal(1)} />
                <c.CustomRadio md="3" label="Cheque" name="ptin" checked={val.ptin === 2} onChange={() => onSetVal(2)} />
                <c.CustomRadio md="3" label="MoMo" name="ptin" checked={val.ptin === 3} onChange={() => onSetVal(3)} />
                <c.CustomRadio md="3" label="Cash" name="ptin" checked={val.ptin === 0} onChange={() => onSetVal(0)} />
              </s.Row>
              </>
            }
            items={deckitems}
          />
        </s.Col>
      </s.Row>
    </s.Container>
  );
}
export default AddNewSales;
