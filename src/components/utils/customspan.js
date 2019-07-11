import React from 'react'






const CustomSpan = ({title, value}) => {



  return (
    <span className="d-flex mb-2">
      {/*}<i className="material-icons mr-1">flag</i>*/}
      <strong className="mr-1">{ title }</strong>{" "}
      <a className="ml-auto">
        { value }
      </a>
    </span>
  );
}

export default CustomSpan;
