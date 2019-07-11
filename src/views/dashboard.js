import React from "react";
import PropTypes from "prop-types";
import * as s from "shards-react";


import * as c from '../components'


const Dashboard = ({ smallStats,linechartOptions,linechartData }) => (
  <s.Container fluid className="main-content-container px-4">
    {/* Page Header */}
    <s.Row noGutters className="page-header py-4">

    </s.Row>

    {/* Small Stats Blocks */}
    <s.Row>
      {smallStats.map((stats, idx) => (
        <s.Col className="col-lg mb-4 animated rollIn" key={idx} {...stats.attrs}>
        <c.StatsCard
          id={`small-stats-${idx}`}
          variation="1"
          chartData={stats.datasets}
          chartLabels={stats.chartLabels}
          label={stats.label}
          value={stats.value}
          percentage={stats.percentage}
          increase={stats.increase}
          decrease={stats.decrease}
        />
        </s.Col>
      ))}
    </s.Row>

    <s.Row>
      {/* Users Overview */}
      <s.Col lg="6" md="12" sm="12" className="mb-4 animated fadeIn">
        <c.CustomCard
          title="Daily Sales"
          subtitle="View Full Report &rarr;"
          children={<c.CustomLineChart chartOptions={linechartOptions} chartData={linechartData}/>}
        />
      </s.Col>

      {/* Users by Device */}
      <s.Col lg="6" md="12" sm="12" className="mb-4 animated fadeIn">
        <c.CustomCard
          title="Month Sales"
          subtitle="View Full Report &rarr;"
          children={<c.CustomLineChart chartOptions={linechartOptions} chartData={linechartData}/>}
        />
      </s.Col>

      {/* New Draft */}
      <s.Col lg="4" md="6" sm="12" className="mb-4">

      </s.Col>

      {/* Discussions */}
      <s.Col lg="5" md="12" sm="12" className="mb-4">

      </s.Col>

      {/* Top Referrals */}
      <s.Col lg="3" md="12" sm="12" className="mb-4">

      </s.Col>
    </s.Row>
    {/*}<s.Row>
      <s.Col lg="12" md="12" sm="12" className="mb-4">
      <c.CustomCard
        title="Latest Sales"
        children={
          <table className="table mb-0">
              <thead className="bg-light">
                <tr>
                  <th scope="col" className="border-0">
                    #
                  </th>
                  <th scope="col" className="border-0">
                    First Name
                  </th>
                  <th scope="col" className="border-0">
                    Last Name
                  </th>
                  <th scope="col" className="border-0">
                    Country
                  </th>
                  <th scope="col" className="border-0">
                    City
                  </th>
                  <th scope="col" className="border-0">
                    Phone
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>1</td>
                  <td>Ali</td>
                  <td>Kerry</td>
                  <td>Russian Federation</td>
                  <td>Gdańsk</td>
                  <td>107-0339</td>
                </tr>
                <tr>
                  <td>2</td>
                  <td>Clark</td>
                  <td>Angela</td>
                  <td>Estonia</td>
                  <td>Borghetto di Vara</td>
                  <td>1-660-850-1647</td>
                </tr>
                <tr>
                  <td>3</td>
                  <td>Jerry</td>
                  <td>Nathan</td>
                  <td>Cyprus</td>
                  <td>Braunau am Inn</td>
                  <td>214-4225</td>
                </tr>
                <tr>
                  <td>4</td>
                  <td>Colt</td>
                  <td>Angela</td>
                  <td>Liberia</td>
                  <td>Bad Hersfeld</td>
                  <td>1-848-473-7416</td>
                </tr>
              </tbody>
            </table>
        }
      />
      </s.Col>
    </s.Row>*/}

  </s.Container>
);

Dashboard.propTypes = {
  /**
   * The small stats dataset.
   */
  smallStats: PropTypes.array
};

Dashboard.defaultProps = {
  smallStats: [
    {
      label: "Total Products",
      value: "5",
      percentage: "4.7%",
      increase: true,
      chartLabels: [null, null, null, null, null, null, null],
      attrs: { md: "6", sm: "6" },
      datasets: [
        {
          label: "Today",
          fill: "start",
          borderWidth: 1.5,
          backgroundColor: "rgba(0, 184, 216, 0.1)",
          borderColor: "rgb(0, 184, 216)",
          data: [1, 2, 1, 3, 5, 4, 7]
        }
      ]
    },
    {
      label: "Total Clients",
      value: "182",
      percentage: "12.4",
      increase: true,
      chartLabels: [null, null, null, null, null, null, null],
      attrs: { md: "6", sm: "6" },
      datasets: [
        {
          label: "Today",
          fill: "start",
          borderWidth: 1.5,
          backgroundColor: "rgba(255,65,105,0.1)",
          borderColor: "rgb(255,65,105)",
          data: [1, 2, 3, 3, 3, 4, 4]
        }
      ]
    }
  ],
  linechartOptions:{
    responsive: true,
    legend: {
      position: "top"
    },
    elements: {
      line: {
        // A higher value makes the line look skewed at this ratio.
        tension: 0.3
      },
      point: {
        radius: 0
      }
    },
    scales: {
      xAxes: [
        {
          gridLines: false,
          ticks: {
            callback(tick, index) {
              // Jump every 7 values on the X axis labels to avoid clutter.
              return index % 7 !== 0 ? "" : tick;
            }
          }
        }
      ],
      yAxes: [
        {
          ticks: {
            suggestedMax: 45,
            callback(tick) {
              if (tick === 0) {
                return tick;
              }
              // Format the amounts using Ks for thousands.
              return tick > 999 ? `${(tick / 1000).toFixed(1)}K` : tick;
            }
          }
        }
      ]
    },
    hover: {
      mode: "nearest",
      intersect: false
    },
    tooltips: {
      custom: false,
      mode: "nearest",
      intersect: false
    }
  },
  linechartData: {
    labels: Array.from(new Array(30), (_, i) => (i === 0 ? 1 : i)),
    datasets: [
      {
        label: "Current Month",
        fill: "start",
        data: [
          500,
          800,
          320,
          180,
          240,
          320,
          230,
          650,
          590,
          1200,
          750,
          940,
          1420,
          1200,
          960,
          1450,
          1820,
          2800,
          2102,
          1920,
          3920,
          3202,
          3140,
          2800,
          3200,
          3200,
          3400,
          2910,
          3100,
          4250
        ],
        backgroundColor: "rgba(0,123,255,0.1)",
        borderColor: "rgba(0,123,255,1)",
        pointBackgroundColor: "#ffffff",
        pointHoverBackgroundColor: "rgb(0,123,255)",
        borderWidth: 1.5,
        pointRadius: 0,
        pointHoverRadius: 3
      },
      {
        label: "Past Month",
        fill: "start",
        data: [
          380,
          430,
          120,
          230,
          410,
          740,
          472,
          219,
          391,
          229,
          400,
          203,
          301,
          380,
          291,
          620,
          700,
          300,
          630,
          402,
          320,
          380,
          289,
          410,
          300,
          530,
          630,
          720,
          780,
          1200
        ],
        backgroundColor: "rgba(255,65,105,0.1)",
        borderColor: "rgba(255,65,105,1)",
        pointBackgroundColor: "#ffffff",
        pointHoverBackgroundColor: "rgba(255,65,105,1)",
        borderDash: [3, 3],
        borderWidth: 1,
        pointRadius: 0,
        pointHoverRadius: 2,
        pointBorderColor: "rgba(255,65,105,1)"
      }
    ]
  }
};

export default Dashboard;
