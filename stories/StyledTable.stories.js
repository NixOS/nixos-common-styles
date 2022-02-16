import '../src/index.less';

export const StyledTable = ({ striped = false }) => {
  const className = ["styled-table"];

  if (striped) {
    className.push(`-striped`);
  }
  const el = document.createElement('table');

  el.innerHTML = `
  <thead>
    <tr>
      <th>Column A</th>
      <th>Column B</th>
      <th>Column C</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Content 1</td>
      <td>Content 1</td>
      <td>Content 1</td>
    </tr>
    <tr>
      <td>Content 1</td>
      <td>Content 1</td>
      <td>Content 1</td>
    </tr>
    <tr>
      <td>Content 1</td>
      <td>Content 1</td>
      <td>Content 1</td>
    </tr>
    <tr>
      <td>Content 1</td>
      <td>Content 1</td>
      <td>Content 1</td>
    </tr>
  </tbody>
  `;
  if (className.length > 0) {
    el.className = className.join(' ');
  }
  console.log(className);

  return el;
};

export default {
  title: 'Components/StyledTable', 
  component: StyledTable,
  argTypes : {
    striped: {
      control: {
        type: 'boolean',
      },
    },
  },
}
