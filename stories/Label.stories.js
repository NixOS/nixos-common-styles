import '../src/index.less';

export const Label = ({ content, type }) => {
  const className = ["label"];

  if (type && type != '(none)') {
    className.push(`-${type}`);
  }
  const el = document.createElement('span');

  el.innerHTML = content;
  if (className.length > 0) {
    el.className = className.join(' ');
  }

  return el;
};

export default {
  title: 'Components/Label', 
  component: Label,
  argTypes : {
    content: {
      control: 'text',
      defaultValue: 'Label <i>HTML</i> content',
    },
    type: {
      control: {
        type: 'select',
        options: ['(none)', 'info', 'success', 'warning', 'danger']
      },
    },
  },
}
