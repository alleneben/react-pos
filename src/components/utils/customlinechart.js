import React, { useEffect } from "react";
import Chart from "./chart";


const didMount = (canvasRef,chartData,chartOptions) => {
  useEffect(() => {

    const LineChart = new Chart(canvasRef.current, {
      type: "LineWithLine",
      data: chartData,
      options: chartOptions
    });

    // They can still be triggered on hover.
    const buoMeta = LineChart.getDatasetMeta(0);
    buoMeta.data[0]._model.radius = 0;
    buoMeta.data[
      chartData.datasets[0].data.length - 1
    ]._model.radius = 0;

    // Render the chart.
    LineChart.render();


    return function cleanup() {

    }
  })

  return true;
}



const CustomLineChart = ({chartData, chartOptions}) => {

  let canvasRef = React.createRef();

  didMount(canvasRef,chartData,chartOptions);

  return (
    <canvas
      height="120"
      ref={canvasRef}
      style={{ maxWidth: "100% !important" }}
    />
  );
}


export default CustomLineChart;
