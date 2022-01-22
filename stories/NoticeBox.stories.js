import '../src/index.less';

export const Noticebox = ({ content, type, slim }) => {
  const className = ["notice-box"];

  if (type && type != '(none)') {
    className.push(`-${type}`);
  }
  if (slim) {
    className.push("-slim");
  }
  const aside = document.createElement('aside');

  aside.innerHTML = content;
  if (className.length > 0) {
    aside.className = className.join(' ');
  }

  return aside;
};

export default {
  title: 'Components/Noticebox', 
  component: Noticebox,
  argTypes : {
    content: {
      control: 'text',
      defaultValue: 'Box <b>content</b>',
    },
    type: {
      control: {
        type: 'select',
        options: ['(none)', 'info', 'warning', 'danger']
      },
    },
    slim: {
      control: {
        type: 'boolean',
      },
    },
  },
}
