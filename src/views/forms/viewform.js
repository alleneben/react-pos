import React, { useState} from 'react'

import * as s from '../../shardslib';
import * as c from '../../components';

import utils from '../../appstate/utils';
import api from  '../../appstate/api';


function ViewForm({item, closeviewform}) {

  const [val, setValue]=useState(item);

  const closeform = () => {
    closeviewform()
  }

  const formtype = (item) => {

    var content = item.mrl ?
    <>
      <c.InputField id="feUsername" md="6" label="Item" placeholder="Username" readOnly="readOnly" type='text'  value={val.nam} />
      <c.InputField id="feUsername" md="6" label="Price" placeholder="Username" readOnly="readOnly" type='text' value={val.prc} />
      <c.InputField id="feUsername" md="6" label="Qty" placeholder="Username" readOnly="readOnly" type='text' value={val.qty} />
      <c.InputField id="feUsername" md="6" label="Date" placeholder="Username" readOnly="readOnly" type='text' value={val.doc} />
      <c.InputField id="feUsername" md="6" label="Time" placeholder="Username" readOnly="readOnly" type='text' value={val.toc} />
      <c.InputField id="feUsername" md="6" label="Status" placeholder="Username" readOnly="readOnly" type='text' value={val.stn} />
    </>
    :
    <>
      <c.InputField id="ProductName" t='t' md="6" label="Product Name" readOnly="readOnly" placeholder="Product Name" type='text' name="nam" value={val.nam} />
      <c.InputField id="CostPrice" md="3" label="Cost Price" placeholder="Cost Price" readOnly="readOnly" type='number' name="bpr" value={val.bpr}/>
      <c.InputField id="RetailSalePrice1" md="3" label="Retail Sale Price 1" placeholder="Retail Sale Price 1" readOnly="readOnly" type='number' name="prc" value={val.prc}/>
      <c.InputField id="RetailSalePrice2" md="3" label="Retail Sale Price 2" placeholder="Retail Sale Price 2" readOnly="readOnly" type='number' name="rsb" value={val.rsb} />
      <c.InputField id="WholeSalePrice" md="3" label="Whole Sale Price" placeholder="WholeSalePrice" readOnly="readOnly" type='number' name="wrsb" value={val.wrsb}/>
      <c.InputField id="Total Qty" md="3" label="Quantity" placeholder="Quantity" readOnly="readOnly" type='number' name="qty" value={val.qty}/>
      <c.InputField id="Qtygroupings " md="3" label="Qty/groupings" placeholder="Qty/groupings" readOnly="readOnly" type='number' name="qpb" value={val.qpb}/>
      <c.InputField id="Category " md="3" label="Category" placeholder="Category" readOnly="readOnly" type='text' name="ctn" value={val.ctn}/>
      <c.InputField id="Unit " md="3" label="Unit" placeholder="Unit" readOnly="readOnly" type='text' name="unt" value={val.unt}/>
    </>

    return content;
  }
  return(
    <React.Fragment>
      <s.ListGroup flush>
        <s.ListGroupItem className="p-3">
          <s.Row>
            <s.Col>
              <s.Form>
                <s.Row form>
                  { formtype(item) }
                </s.Row>
                <s.Button theme="danger" onClick={closeform}>Close</s.Button>
              </s.Form>
            </s.Col>
          </s.Row>
        </s.ListGroupItem>
      </s.ListGroup>
    </React.Fragment>
  );
}


export default ViewForm;
