import React, { useState} from 'react'

import * as s from '../../shardslib';
import * as c from '../../components';

import utils from '../../appstate/utils';
import api from  '../../appstate/api';

let form;
function EditForm({item,submit,fmtype,closeeditform,animated,cboc,cbou,flds}) {

  const [val, setvalue]=useState(flds);
  const [sdt, setdat] = useState(undefined);
  const [selectedoption,setselectedoption] = useState(null);


  const handlesubmit = (f,s,a) => {
    // val.sdtt = !!val.sdtt ? val['sdtt'].toString() : ''
    submit({val:val,sdt:sdt,form:form.props.children,f:f,s:s,a:a})
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

  const closeform = () => {
    closeeditform(true)
  }


  const makeform = (fmtype) => {
    var content = fmtype === 'edit product' ?
    <>
      <c.InputField id="rid" hidden={true} md="12" type='text' name="ridn" value={val.ridn} onChange={onChange} formtype='edit'/>
      <c.InputField id="ProductName" t='t' md="6" label="Product Name" placeholder="Product Name" type='text' name="namt" value={val.namt} onChange={onChange} formtype='edit'/>
      <c.InputField id="CostPrice" md="3" label="Cost Price" placeholder="Cost Price" type='number' name="bprn" value={val.bprn} onChange={onChange} formtype='edit'/>
      <c.InputField id="RetailSalePrice1" md="3" label="Retail Sale Price 1" placeholder="Retail Sale Price 1" type='number' name="prcn" value={val.prcn} onChange={onChange} formtype='edit'/>
      <c.InputField id="RetailSalePrice2" md="3" label="Retail Sale Price 2" placeholder="Retail Sale Price 2" type='number' name="rsbn" value={val.rsbn || ''} onChange={onChange}/>
      <c.InputField id="WholeSalePrice" md="3" label="Whole Sale Price" placeholder="WholeSalePrice" type='number' name="wrsbn" value={val.wrsbn} onChange={onChange} formtype='edit'/>
      <c.InputField id="Total Qty" md="3" label="Quantity" placeholder="Quantity" type='number' name="qtyn" value={val.qtyn} onChange={onChange} formtype='edit'/>
      <c.InputField id="Qtygroupings " md="3" label="Qty/groupings" placeholder="Qty/groupings" type='number' name="qpbn" value={val.qpbn} onChange={onChange} formtype='edit'/>
      <c.SelectField id="Category" md="3" label="Category" name="cidn" value={val.cidn}   onChange={onSelectChange} options={cboc} formtype='edit' />
      <c.SelectField id="Units" md="3" label="Units" name="unin"  value={val.unin} onChange={onSelectChange} options={cbou} formtype='edit' />
    {/*<c.DateField  id="ExpiryDate" md="6" label="Expiry Date" placeholder="Expiry Date" name="sdtt" value={val.edt || ''} onChange={onDateChange}/>*/}
      <c.InputArea id="Description" md="12" row="3" label="Description" placeholder="Description" type='text' name="dsct" value={val.dsct} onChange={onChange} formtype='edit'/>
      <div><s.Button theme="danger" onClick={closeform}>Discard</s.Button> &nbsp;&nbsp;&nbsp;  <s.Button onClick={() => handlesubmit('sp_product_edit','ad','addproduct')}>Update Product</s.Button></div>
    </>
    :
    <>
      <c.InputField id="feUsername" md="12" label="Name" placeholder="Name" type='text' name="nam" value={val.nam} onChange={onChange} />
    </>

    return content;
  }

  return(
    <React.Fragment>
      <s.ListGroup flush>
        <s.ListGroupItem className="p-3">
          <s.Row>
            <s.Col>
              { /*progress && <c.ProgressBar theme="success" value={progressvalue}/>*/}
              <s.Form >
              <h5>{fmtype.toUpperCase()}</h5>
                <s.Row form>
                  { form = makeform(fmtype) }
                </s.Row>
                {/*<br/>
                <s.Button theme="danger" onClick={closeform}>Discard</s.Button> &nbsp;&nbsp;&nbsp;  <s.Button onClick={handlesubmit}>Update Product</s.Button>*/}
              </s.Form>
            </s.Col>
          </s.Row>
        </s.ListGroupItem>
      </s.ListGroup>
    </React.Fragment>
  );
}


export default EditForm;
