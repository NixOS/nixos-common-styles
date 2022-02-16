import './footer.less';

export const Footer = ({ }) => {
  const dom = document.createElement('div');
  dom.innerHTML = (`
  <footer>
    <div>
      <div class="upper">
        <section>
          <h4>The project</h4>
          <ul>
            <li><a href="https://status.nixos.org/">Channel Status</a></li>
            <li><a href="https://search.nixos.org/packages">Packages search</a></li>
            <li><a href="https://search.nixos.org/options">Options search</a></li>
            <li><a href="/community/teams/security.html">Security</a></li>
          </ul>
        </section>
        <section>
          <h4>Get in Touch</h4>
          <ul>
            <li><a href="https://discourse.nixos.org/">Forum</a></li>
            <li><a href="https://matrix.to/#/#community:nixos.org">Matrix Chat</a></li>
            <li><a href="/community/commercial-support.html">Commercial support</a></li>
          </ul>
        </section>
        <section>
          <h4>Contribute</h4>
          <ul>
            <li><a href="/guides/contributing.html">Contributing Guide</a></li>
            <li><a href="/donate.html">Donate</a></li>
          </ul>
        </section>
        <section>
          <h4>Stay up to date</h4>
          <ul>
            <li><a href="/blog/index.html">Blog</a></li>
            <li><a href="https://weekly.nixos.org/">Newsletter</a></li>
          </ul>
        </section>
      </div>
      <hr />
      <div class="lower">
        <section class="footer-copyright">
          <h4>NixOS</h4>
          <div>
            <span>
              Copyright © 2022 NixOS contributors
            </span>
            <a href="https://github.com/NixOS/nixos-homepage/blob/master/LICENSES/CC-BY-SA-4.0.txt">
              <abbr title="Creative Commons Attribution Share Alike 4.0 International">
                CC-BY-SA-4.0
              </abbr>
            </a>
          </div>
        </section>
        <section class="footer-social">
          <h4>Connect with us</h4>
          <ul>
            <li class="social-icon -twitter"><a href="https://twitter.com/nixos_org">Twitter</a></li>
            <li class="social-icon -youtube"><a
                href="https://www.youtube.com/channel/UC3vIimi9q4AT8EgxYp_dWIw">Youtube</a></li>
            <li class="social-icon -github"><a href="https://github.com/NixOS">GitHub</a></li>
          </ul>
        </section>
      </div>
    </div>
  </footer>
  `);

  return dom.querySelector("footer");
};

export default {
  title: 'Layout/Footer', 
  component: Footer,
  argTypes : {
    // For now, nothing configurable...
    // Storybook doesn't provide neat semantics to build menus :/...
  },
}
