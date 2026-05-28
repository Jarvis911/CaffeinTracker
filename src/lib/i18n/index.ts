import { browser } from '$app/environment';
import { init, register, getLocaleFromNavigator } from 'svelte-i18n';

register('en', () => import('./en.json'));
register('vi', () => import('./vi.json'));

const defaultLocale = 'en';

init({
	fallbackLocale: defaultLocale,
	initialLocale: browser ? window.localStorage.getItem('locale') || getLocaleFromNavigator() : defaultLocale,
});
