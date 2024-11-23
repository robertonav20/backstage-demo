import TitilliumWebBold from './fonts/TitilliumWeb-Bold.ttf';
import TitilliumWebItalic from './fonts/TitilliumWeb-Italic.ttf';
import TitilliumWebRegular from './fonts/TitilliumWeb-Regular.ttf';
import UbuntuBold from './fonts/Ubuntu-Bold.ttf';
import UbuntuItalic from './fonts/Ubuntu-Italic.ttf';
import UbuntuRegular from './fonts/Ubuntu-Regular.ttf';

import {
    createUnifiedTheme,
    palettes,
} from '@backstage/theme';

const appFontName = 'AppFont';

const appFont = {
    fontFamily: appFontName,
    // fontStyle: 'normal',
    // fontDisplay: 'swap',
    // fontWeight: 300,
    src: `local(${appFontName}), url(${TitilliumWebBold}) format('woff2')`,
};

export const appTheme = createUnifiedTheme({
    fontFamily: appFontName,
    palette: palettes.dark,
    components: {
        MuiCssBaseline: {
            styleOverrides: {
                '@font-face': [appFont],
            },
        },
    },
});