import React, { useState } from "react";
import { Button, Modal, ModalBody, ModalHeader } from "shards-react";
let paid;
let tot;
let bal;
let discount;
const CustomModal = ({ open, submit,closemodal, children,items, title }) =>  {

  // const [open, setopen] = useState(open);
  paid = children.props.children[1].props.children[1].props.value;
  tot = (children.props.children[0].props.children[1]-children.props.children[0].props.children[5]).toFixed(2);
  bal = (paid - tot).toFixed(2);
  const toggle = (type) => {
    if(type){
      submit(items)
    }else {
      closemodal()
    }
  }
  return (
    <div>
      <Modal open={open} toggle={toggle} onClick={toggle}>
        <ModalHeader>Bal: GHC { bal }</ModalHeader>
        <ModalBody>{ children }</ModalBody>
          {paid && <Button theme="danger" className="btn-block custom-btn" onClick={() => toggle('click')}>Submit</Button>}
      </Modal>
    </div>
  );
}

export default CustomModal;
