import './page-title.less';

export const PageTitle = ({ content, }) => {
  const className = ["page-title"];

  const dom = document.createElement('div');
  dom.innerHTML = (`
  <div class="page-title">
    <h1>${content}</h1>
  </div>
  `);

  return dom.querySelector(":first-child");
};

export default {
  title: 'Components/PageTitle', 
  component: PageTitle,
  argTypes : {
    content: {
      control: 'text',
      defaultValue: 'Page title',
    },
  },
}
