import React from "react";
import { Doughnut } from "react-chartjs-2";

const Piechart = ({ user }) => {
  var es = 0;
  var g = 0;
  var en = 0;
  user.transactions.forEach((c) => {
    if (c.category === "Essentials") {
      es += 1;
    } else if (c.category === "Gifts") {
      g += 1;
    } else {
      en += 1;
    }
  });

  return (
    <div className="pie-chart">
      <Doughnut
        data={{
          datasets: [
            {
              data: [es, g, en],
            },
          ],
          labels: ["Essentials", "Gifts", "Entertainment"],
        }}
      />
    </div>
  );
};
export default Piechart;
