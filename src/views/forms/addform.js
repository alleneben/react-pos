import React, { useState} from 'react'

import * as s from '../../shardslib';
import * as c from '../../components';

import utils from '../../appstate/utils';
import api from  '../../appstate/api';

let form;
function AddForm({submit,fmtype,closeaddform,clearaddform,animated,cboc,cbou}) {

  const [val, setvalue]=useState({});
  const [sdt, setdat] = useState(undefined);
  const [selectedoption,setselectedoption] = useState(null);

  const handlesubmit = (dbf,s,a) => {
    // val.sdtt = !!val.sdtt ? val['sdtt'].toString() : '';
    // console.log(val);
    submit({val:val,sdt:sdt,form:form.props.children,f:dbf,s:s,a:a});
  }


  const onChange = (e)=>  setvalue({...val, [e.target.name]: e.target.value})

  const onDateChange = (value) =>{
    var dt = new Date(value);
    setvalue({...val,['sdtt']: value})
  }
  const onSetVal = (e) =>{
     setvalue({...val, ptin: e})
   }

  const onSelectChange = (e) => {
    setvalue({...val, [e.nam]: e.value});
  }

  const closeform = () => {
    closeaddform(true)
  }

  const clearform = () => {
    setvalue({})
  }

  const makeform = (fmtype) => {
    var content = fmtype === 'products' ?
    <>
      <c.InputField id="ProductName" t='t' md="6" label="Product Name" placeholder="Product Name" type='text' name="namt" value={val.namt || ''} onChange={onChange} formtype='add'/>
      <c.InputField id="CostPrice" md="3" label="Cost Price" placeholder="Cost Price" type='number' name="bprn" value={val.bprn || ''} onChange={onChange} formtype='add'/>
      <c.InputField id="RetailSalePrice1" md="3" label="Retail Sale Price 1" placeholder="Retail Sale Price 1" type='number' name="prcn" value={val.prcn || ''} onChange={onChange} formtype='add'/>
      <c.InputField id="RetailSalePrice2" md="3" label="Retail Sale Price 2" placeholder="Retail Sale Price 2" type='number' name="rsbn" value={val.rsbn || ''} onChange={onChange} formtype='add'/>
      <c.InputField id="WholeSalePrice" md="3" label="Whole Sale Price" placeholder="WholeSalePrice" type='number' name="wcpn" value={val.wcpn || ''} onChange={onChange} formtype='add'/>
      <c.InputField id="Total Qty" md="3" label="Quantity" placeholder="Quantity" type='number' name="qtyn" value={val.qtyn || ''} onChange={onChange} formtype='add'/>
      <c.InputField id="Qtygroupings " md="3" label="Qty/groupings" placeholder="Qty/groupings" type='number' name="gtyn" value={val.gtyn || ''} onChange={onChange} formtype='add'/>
      <c.SelectField id="Category" md="3" label="Category" name="cidn" value={val.cidn || ''}   onChange={onSelectChange} options={cboc}  />
      <c.SelectField id="Units" md="3" label="Units" name="unin" value={val.unin || ''} onChange={onSelectChange} options={cbou} />
      <c.DateField  id="ExpiryDate" md="6" label="Expiry Date" placeholder="Expiry Date" name="sdtt" value={val.sdtt || ''} onChange={onDateChange}/>
      <c.InputArea id="Description" md="12" row="3" label="Description" placeholder="Description" type='text' name="dsct" value={val.dsct || ''} onChange={onChange}/>
      <div><s.Button theme="danger" onClick={clearform}>Clear</s.Button> &nbsp;&nbsp;&nbsp;  <s.Button theme="danger" onClick={closeform}>Discard</s.Button> &nbsp;&nbsp;&nbsp;  <s.Button onClick={() => handlesubmit('sp_product_add','ad','addproduct')}>Save</s.Button></div>
    </>
    :
    fmtype === 'customer' ?
    <>
      <c.InputField id="Surname" t='t' md="3" label="Surname" placeholder="Surname" type='text' name="snmt" value={val.snmt || ''} onChange={onChange} formtype='add'/>
      <c.InputField id="Firstname" md="3" label="Firstname" placeholder="Firstname" type='text' name="fnmt" value={val.fnmt || ''} onChange={onChange} formtype='add'/>
      <c.InputField id="Mobile1" md="3" label="Mobile 1" placeholder="Mobile 1" type='number' name="telt" value={val.telt || ''} onChange={onChange} formtype='add'/>
      <c.InputField id="Mobile2" md="3" label="Mobile 2" placeholder="Mobile 2" type='number' name="mbnt" value={val.mbnt || ''} onChange={onChange} formtype='add'/>
      <c.InputField id="NextofKin" md="6" label="Next of Kin name" placeholder="Next of Kin name" type='text' name="nokt" value={val.nokt || ''} onChange={onChange} formtype='add'/>
      <c.InputField id="NextofKinPhone" md="3" label="Next of Kin Phone" placeholder="Next of Kin Phone" type='number' name="nfkt" value={val.nfkt || ''} onChange={onChange} formtype='add'/>
      <c.InputField id="NextofKinRel" md="3" label="Relationship" placeholder="Relationship" type='text' name="relt" value={val.relt || ''} onChange={onChange} formtype='add'/>
      <c.CustomRadio id="radio" md="6" label="Savings Account" name="ptin" value={val.ptin || ''} checked={val.ptin === 1} onChange={() => onSetVal(1)} />
      <c.CustomRadio id="radio" md="6" label="Hire Purchase Account" name="ptin" value={val.ptin || ''} checked={val.ptin === 2} onChange={() => onSetVal(2)} />
      <c.InputArea id="Address" md="12" row="3" label="Address" placeholder="Address" type='text' name="hadt" value={val.hadt || ''} onChange={onChange}/>
      <div><s.Button theme="danger" onClick={clearform}>Clear</s.Button> &nbsp;&nbsp;&nbsp;  <s.Button theme="danger" onClick={closeform}>Discard</s.Button> &nbsp;&nbsp;&nbsp;  <s.Button onClick={() => handlesubmit('sp_member_add','ad','AddMember')}>Save</s.Button></div>
    </> :
    <>
      <c.InputField id="Name" md="12" label="Name" placeholder="Name" type='text' name="namt" value={val.namt || ''} onChange={onChange} />
      <div><s.Button theme="danger" onClick={clearform}>Clear</s.Button> &nbsp;&nbsp;&nbsp; <s.Button onClick={() => handlesubmit('sp_category_add','ad','addproduct')}>Save</s.Button></div>
    </>

    return content;
  }

  return(
    <React.Fragment>
      <s.ListGroup flush>
        <s.ListGroupItem className={animated}>
          <s.Row>
            <s.Col>
              <s.Form >
              <h5>{fmtype.toUpperCase()}</h5>
                <s.Row form>
                  { form = makeform(fmtype) }
                </s.Row>
                {/*<br/>
                <s.Button theme="danger" onClick={clearform}>Clear</s.Button> &nbsp;&nbsp;&nbsp;  <s.Button theme="danger" onClick={closeform}>Discard</s.Button> &nbsp;&nbsp;&nbsp;  <s.Button onClick={handlesubmit}>Save</s.Button>*/}
              </s.Form>
            </s.Col>
          </s.Row>
        </s.ListGroupItem>
      </s.ListGroup>
    </React.Fragment>
  );
}


export default AddForm;
