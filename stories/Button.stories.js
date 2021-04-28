import '../src/index.less';

export const Button = ({ label, type }) => {
  const className = [];

  if (type && type != '(none)') {
    className.push(`-${type}`);
  }
  const btn = document.createElement('button');

  btn.innerText = label;
  if (className.length > 0) {
    btn.className = className.join(' ');
  }

  return btn;
};

export default {
  title: 'Forms/Button', 
  component: Button,
  argTypes : {
    label: {
      control: 'text',
      defaultValue: 'Button label',
    },
    type: {
      control: {
        type: 'select',
        options: ['(none)', 'primary', 'light', 'highlighted']
      },
    },
  },
}
