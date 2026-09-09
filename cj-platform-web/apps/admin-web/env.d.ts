/// <reference types="vite/client" />

interface ImportMetaEnv {
  /** 后端API基础地址；留空时由Vite代理转发到本地8080。 */
  readonly VITE_API_BASE_URL?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
