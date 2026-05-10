const { SSMClient, GetParameterCommand } = require('@aws-sdk/client-ssm');

const ssm = new SSMClient({ region: process.env.AWS_REGION || 'us-east-1' });

async function getParam(name) {
  const cmd = new GetParameterCommand({ Name: name, WithDecryption: true });
  const res = await ssm.send(cmd);
  return res.Parameter.Value;
}

module.exports = { getParam };
