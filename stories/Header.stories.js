import './header.less';

export const Header = ({ title, subtitle, items }) => {
  const className = [];

  const withSubtitle = (subtitle && subtitle != "");
  const subtitleHTML = 
    withSubtitle
    ? `<div class="subtitle">${subtitle}</div>`
    : ""
  ;

  const dom = document.createElement('div');
  dom.innerHTML = (`
  <header>
    <div>
      <h1${withSubtitle && ' class="-with-subtitle"'}>
        <a href="#">${title}</a>
        ${subtitleHTML}
      </h1>
      <nav style="display: none;">
        <ul>
          ${items}
        </ul>
      </nav>
    </div>
    <button class="menu-toggle">Toggle the menu</button>
  </header>
  `);

  return dom.querySelector("header");
};

export default {
  title: 'Layout/Header', 
  component: Header,
  argTypes : {
    title: {
      control: 'text',
      defaultValue: "NixOS",
    },
    subtitle: {
      control: 'text',
      defaultValue: "Storybook",
    },
    items: {
      control: 'text',
      defaultValue: (`
<li class=""><a href="#">Explore</a></li>
<li class=""><a href="#">Download</a></li>
<li class=""><a href="#">Learn</a></li>
<li class=""><a href="#">Community</a></li>
<li class=""><a href="#">Blog</a></li>
<li class=""><a href="#">Donate</a></li>
<li class="search">
  <a href="">Search</a>
</li>
      `).trim(),
    },
  },
}
