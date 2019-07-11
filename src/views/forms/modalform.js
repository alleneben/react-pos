import React, { useState} from 'react'

import * as s from '../../shardslib';
import * as c from '../../components';

import utils from '../../appstate/utils';
import api from  '../../appstate/api';

let form;
function ModalForm({item,submit,fmtype,closemodal,animated,cboc,open,flds}) {

  const [val, setvalue]=useState(flds);
  const [sdt, setdat] = useState(undefined);
  const [selectedoption,setselectedoption] = useState(null);


  const handlesubmit = (t,f,s,a) => {
    if(t){
      submit({val:val,sdt:sdt,form:form.props.children,f:f,s:s,a:a})
    }else {
      closemodal()
    }
    // val.sdtt = !!val.sdtt ? val['sdtt'].toString() : ''
    // submit({val:val,sdt:sdt,form:form.props.children,f:f,s:s,a:a})
  }
  const toggle = (type) => {
    if(type){
      submit(item)
    }else {
      closemodal()
    }
  }



  const onChange = (e) =>  {
    setvalue({...val,[e.target.name]: e.target.value })
  }
  const onDateChange = (value) =>{
    var dt = new Date(value);
    setvalue({...val,['sdtt']: value})
  }

  const onSelectChange = (e) => {
    setvalue({...val, [e.nam]: e.value});
  }

  const makeform = (fmtype) => {
    var content = fmtype === 'edit asset' ?
    <>
      <div><s.Button theme="danger" onClick={closemodal}>Discard</s.Button> &nbsp;&nbsp;&nbsp;  <s.Button onClick={() => handlesubmit('sp_product_edit','ad','addproduct')}>Update Product</s.Button></div>
    </>
    :
    <>
      {/*<c.SelectField id="Location" md="12" label="Location" name="cidn" value={val.cidn || ''}   onChange={onSelectChange} options={cboc}  />*/}
      <c.InputField id="rid" hidden={true} md="12" type='text' name="ridn" value={val.ridn} onChange={onChange} formtype='edit'/>
      <c.InputField id="Location" t='t' md="6" label="Location" placeholder="From" type='text' name="tlot" value={val.tlot || ''} onChange={onChange} formtype='add'/>
      <c.InputField id="To" t='t' md="6" label="Location" placeholder="To" type='text' name="tlct" value={val.tlct || ''} onChange={onChange} formtype='add'/>
      <c.DateField  id="TransferDate" md="12" label="Transfer Date" placeholder="Transfer Date" name="sdtt" value={val.sdtt || ''} onChange={onDateChange}/>
      <c.InputArea id="Remarks" md="12" row="3" label="Remarks" placeholder="Remarks" type='text' name="rmkt" value={val.rmkt || ''} onChange={onChange}/>
      <s.Button theme="danger" className="btn-block custom-btn" onClick={() => handlesubmit('click','sp_asset_transfer','ad','transfer')}>Submit</s.Button>
    </>

    return content;
  }

  return(
    <React.Fragment>
      <s.Modal open={open} toggle={handlesubmit} onClick={handlesubmit}>
        <s.ModalHeader>{ fmtype }</s.ModalHeader>
        <s.ModalBody><s.Row> {form = makeform(fmtype) } </s.Row></s.ModalBody>
      </s.Modal>
    </React.Fragment>
  );
}


export default ModalForm;
