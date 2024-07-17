import React from "react";

import { Bar } from "react-chartjs-2";
import { Chart as ChartJS } from "chart.js/auto";

const Barchart = ({ user }) => {
  var ranges = ["less than 100", "101 to 1000", "greater than 1000"];
  var transactions = [0, 0, 0];
  var investments = [0, 0, 0];
  user.transactions.forEach((t) => {
    if (t.amount <= 100) {
      transactions[0] += 1;
    } else if (t.amount > 1000) {
      transactions[2] += 1;
    } else {
      transactions[1] += 1;
    }
  });
  user.investments.forEach((i) => {
    if (i.amount <= 100) {
      investments[0] += 1;
    } else if (i.amount > 1000) {
      investments[2] += 1;
    } else {
      investments[1] += 1;
    }
  });

  return (
    <div className="bar-chart">
      <Bar
        data={{
          labels: ranges,
          datasets: [
            {
              label: "expenses: ",
              data: transactions,
            },
            {
              label: "investment: ",
              data: investments,
            },
          ],
        }}
        options={{
          maintainAspectRatio: false,
        }}
        height={2000}
        width={3000}
      />
    </div>
  );
};
export default Barchart;
