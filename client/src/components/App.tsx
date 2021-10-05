import { QueryClient, QueryClientProvider } from "react-query";
import { Helmet, HelmetProvider } from "react-helmet-async";

import { Routes } from "components/Routes";

const queryClient = new QueryClient();

export function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <HelmetProvider>
        <Helmet defaultTitle="todotxt-ui" titleTemplate="%s | todotxt-ui" />
        <Routes />
      </HelmetProvider>
    </QueryClientProvider>
  );
}
