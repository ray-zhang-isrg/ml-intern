/**
 * Centralized API utilities.
 *
 * In production: HttpOnly cookie (hf_access_token) is sent automatically.
 * In development: auth is bypassed on the backend.
 */

import { triggerLogin } from '@/hooks/useAuth';

/** Compute the base path for API calls from the current page URL.
 *  Handles Domino's reverse-proxy prefix (e.g. /.../proxy/8890/) transparently. */
function getBasePath(): string {
  let path = window.location.pathname;
  if (!path.endsWith('/')) path += '/';
  return path;
}

/** Resolve an absolute API path (e.g. /api/health) to work behind a reverse proxy. */
export function resolveApiPath(path: string): string {
  if (!path.startsWith('/')) return path;
  return getBasePath() + path.slice(1);
}

/** Wrapper around fetch with credentials and common headers. */
export async function apiFetch(
  path: string,
  options: RequestInit = {}
): Promise<Response> {
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string>),
  };

  const response = await fetch(resolveApiPath(path), {
    ...options,
    headers,
    credentials: 'include', // Send cookies with every request
  });

  // Handle 401 — redirect to login
  if (response.status === 401) {
    try {
      const authStatus = await fetch(resolveApiPath('/auth/status'), { credentials: 'include' });
      const data = await authStatus.json();
      if (data.auth_enabled) {
        triggerLogin();
        throw new Error('Authentication required — redirecting to login.');
      }
    } catch (e) {
      if (e instanceof Error && e.message.includes('redirecting')) throw e;
    }
  }

  return response;
}