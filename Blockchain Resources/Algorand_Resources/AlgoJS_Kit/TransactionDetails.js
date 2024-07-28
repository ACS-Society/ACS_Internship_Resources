import algosdk from 'algosdk';

const algodToken = '';
const algodServer = 'https://testnet-api.algonode.cloud';
const algodPort = 443;
const algodClient = new algosdk.Algodv2(algodToken, algodServer, algodPort);

async function fetchTransactionDetails(transactionId) {
  try {
    const txInfo = await algodClient.pendingTransactionInformation(transactionId).do();
    return txInfo;
  } catch (error) {
    console.error('Error fetching transaction details:', error);
    return null;
  }
}

const transactionId = '6LMDFAMB26D2CU623ZQQHOAWNSTSMA4AGDB2MJVY5JWG5MRVD6HA';

fetchTransactionDetails(transactionId)
  .then(txInfo => {
    if (txInfo) {
      console.log('Transaction Details:', txInfo);
    } else {
      console.log('Transaction not found or an error occurred.');
    }
  })
  .catch(error => {
    console.error('Error:', error);
  });

