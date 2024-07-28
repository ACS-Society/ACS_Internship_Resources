import * as React from "react";
import styled from "styled-components";
import Icon from "./Icon";
import ASAIcon from "./ASAIcon";
import algo from "../assets/algo.svg";
import { formatBigNumWithDecimals } from "../helpers/utilities";
import { IAssetData } from "../helpers/types";

const SAssetRow = styled.div`
  width: 100%;
  padding: 20px;
  display: flex;
  justify-content: space-between;
`;
const SAssetRowLeft = styled.div`
  display: flex;
`;
const SAssetName = styled.div`
  display: flex;
  margin-left: 10px;
`;
const SAssetRowRight = styled.div`
  display: flex;
`;
const SAssetBalance = styled.div`
  display: flex;
`;

const AssetRow = (props: { asset: IAssetData }) => {
  const { asset } = props;
  const nativeCurrencyIcon = asset.id === 0 ? algo : null;
  return (
    <SAssetRow {...props}>
      <SAssetRowLeft>
        {nativeCurrencyIcon ? <Icon src={nativeCurrencyIcon} /> : <ASAIcon assetID={asset.id} />}
        <SAssetName>{asset.name}</SAssetName>
      </SAssetRowLeft>
      <SAssetRowRight>
        <SAssetBalance>
          {`${formatBigNumWithDecimals(asset.amount, asset.decimals)} ${asset.unitName || "units"}`}
        </SAssetBalance>
      </SAssetRowRight>
    </SAssetRow>
  );
};

export default AssetRow;
