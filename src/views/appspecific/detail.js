import React, { useState, useContext, useEffect } from "react";

import * as s from "../../shardslib";
import * as c from '../../components'

import { AppContext } from '../../appstate/appcontext'
import utils from '../../appstate/utils';
import * as a from '../../components/appspecific'

const Detail = (props) => {
  const { state, dispatch } = useContext(AppContext)
  const { data,id } = props.location

  //data
  const [tbdata,settdata] = useState([])
  const [cdata,setcdata] = useState(null)
  // utilities
  const [notify, setnotify] = useState(null)
  const [msg, setmsg] = useState(null)
  const [place, setplace] = useState(null)
  const [theme, settheme] = useState('')
  const [loading, setloading] = useState(false);

  // useEffect(() => {
  //   setloading(true)
  //   utils.utilfxns.fetchdata(id,'savings','','').then(rd => {
  //     setloading(false)
  //     var out = rd;
  //     if (out.success) {
  //       settdata(rd.sd)
  //     } else {
  //       setnotify(true)
  //       setplace('tr')
  //       setmsg(out[0].em)
  //     }
  //   },err => {
  //     setnotify(true)
  //     settheme('danger')
  //     setmsg('Failed to Fetch Asset Data')
  //     setloading(false)
  //   })
  //   return () => {
  //     console.log('bye');
  //   };
  // },[])

  const submit = (fm) => {
    setnotify(null);setmsg(null);setplace(null);
    setloading(true)
    utils.utilfxns.submitdata(fm).then(rd => {
      setloading(false)
      var out = rd;
      if(out.success){
        settdata(rd.sd)
        setnotify(true)
        setplace('tr')
        setmsg('Deposit made successfully')

      } else {
        setnotify(true)
        setplace('tr')
        setmsg(out[0].em)
      }
    })
  }

  const makechildren = () => {
    return  <s.ListGroup flush>
          <s.ListGroupItem className="p-3">
            <c.CustomSpan title='Name' value={data.nam} />
            <c.CustomSpan title='Code' value={data.mno} />
            <c.CustomSpan title='Phoneno 1' value={data.mob} />
            <c.CustomSpan title='Phoneno 2' value={data.tel} />
            <c.CustomSpan title='Next of Kin' value={data.nxk} />
            <c.CustomSpan title='Next of Kin Phoneno' value={data.nkt} />
            <c.CustomSpan title='Address' value={data.had} />
            <c.CustomSpan title='Amount Paid' value={'GHC '+(data.avl * 1).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')} />
            <c.CustomSpan title='Arrears' value={'GHC '+(data.avl * 1).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')} />
          </s.ListGroupItem>
      </s.ListGroup>
  }

  const mkprodtbl = () =>{
    const tbcfg = {header:['S/No','Product','Price','Qty','Date'],flds:[{n:'nam',f:'t'},{n:'prc',f:'d'},{n:'qty',f:'n'},{n:'dat',f:'t'}]}
    const p = '{"mid":"n"}';const params = {fld:'mid',val:id}
    return <c.MagsterDataTable load={true} ttl='Products' height='300px' phld='Items' btns={[]} data={[]} tbcfg={tbcfg} prm={params} svc='fd' a='find' p={p} dbf='cproducts'/>
  }

  const mkpmttbl = () =>{
    const tbcfg = {header:['S/No','Amount','Date'],flds:[{n:'amt',f:'d'},{n:'dcd',f:'t'}]};
    const p = '{"mid":"n"}';const params = {fld:'mid',val:id}
    return <c.MagsterDataTable load={true} ttl='Payments' height='300px' phld='Items' btns={[]} data={tbdata || []} tbcfg={tbcfg} prm={params} svc='fd' a='find' p={p} dbf='savings'/>
  }


  return (
    <s.Container fluid className="main-content-container px-4 pb-4">
    {/* Page Header */}

    <s.Row noGutters className="page-header py-4">
    </s.Row>

    <s.Row>
      {/* Editor */}
      <s.Col lg="4" md="12">
        {data && <c.CustomCard clsnm='animated fadeIn' title={ data.nam} children={ makechildren() }/>}
      </s.Col>

      <s.Col lg="4" md="12">
        {data &&   mkpmttbl()}
      </s.Col>

      {/* Sidebar Widgets */}
      <s.Col lg="4" md="12">
        <a.Actions clsnm='mb-3 animated lightSpeedIn' placeholder="Amount" submit={submit} data={data} cid={id}/>

      </s.Col>
    </s.Row>
    <br/>
    <s.Row>
      <s.Col lg="6" md="12">
        {data && mkprodtbl() }
      </s.Col>
    </s.Row>
    { notify && msg && place && <c.Notification place={place} type='danger' msg={msg} time='3'/>}
  </s.Container>
  );
}
export default Detail;
