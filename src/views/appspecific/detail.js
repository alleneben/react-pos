import React, { useReducer, useContext, useEffect } from "react";

import * as s from "../../shardslib";
import * as c from '../../components'

import { AppContext } from '../../appstate/appcontext'
import utils from '../../appstate/utils';
import * as a from '../../components/appspecific'

const Detail = (props) => {
  const [cstate, setState] = useReducer(
    (cstate, newState) => ({...cstate, ...newState}),{
      loading: false, place:null, msg:null, notify:null,tbdata: [],sum:0.0}
    )

  const { state, dispatch } = useContext(AppContext)
  const { data,id } = props.location



  useEffect(() => {
    setState({loading:true, notify:null, msg:null, place:null})
    utils.utilfxns.submitdata({val:{cidn:id},sdt:'',form:'',dbf:'sp_cproducts_find',s:'fd',a:'find'}).then(rd => {
      setState({loading:false})
      let out = rd;
      if(out.success){
        let sum=0.0
        out.sd.map((d,k)=>{
          sum = sum + (parseFloat(d.tot));
        })
        setState({sum:sum})
      } else {
        setState({notify:true, msg:out[0].em, place:'tr'})

      }
    })
  },[])
  const submit = (fm) => {
    setState({loading:true, notify:null, msg:null, place:null})
    utils.utilfxns.submitdata(fm).then(rd => {
      setState({loading:true})
      var out = rd;
      if(out.success){
        setState({notify:true, msg:'Deposit made successfully', place:'tr', tbdata:rd.sd})
      } else {
        setState({notify:true, msg:out[0].em, place:'tr'})

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
            <c.CustomSpan title='Amount Paid' value={'GHC '+(data.tot * 1).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')} />
            <c.CustomSpan title='Products Bought' value={'GHC '+(cstate.sum * 1).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')} />
          </s.ListGroupItem>
      </s.ListGroup>
  }

  const mkprodtbl = () =>{
    const tbcfg = {header:['S/No','Product','Price','Qty','Date'],flds:[{n:'nam',f:'t'},{n:'prc',f:'d'},{n:'qty',f:'n'},{n:'dat',f:'t'}]}
    const p = '{"mid":"n"}';const spm = {mid:id}
    return <c.MagsterDataTable load={true} ttl='Products' height='300px' phld='Items' btns={[]} data={[]} tbcfg={tbcfg} spm={spm} svc='fd' a='find' p={p} dbf='cproducts'/>
  }

  const mkpmttbl = () =>{
    const tbcfg = {header:['S/No','Amount','Date'],flds:[{n:'amt',f:'d'},{n:'dcd',f:'t'}]};
    const p = '{"mid":"n"}';const spm = {mid:id}
    return <c.MagsterDataTable load={true} ttl='Payments' height='300px' phld='Items' btns={[]} data={cstate.tbdata || []} tbcfg={tbcfg} spm={spm} svc='fd' a='find' p={p} dbf='savings'/>
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
    { cstate.notify && cstate.msg && cstate.place && <c.Notification place={cstate.place} type='danger' msg={cstate.msg} time='3'/>}
  </s.Container>
  );
}
export default Detail;
