import { ChakraProvider } from '@chakra-ui/react'
import type { AppProps } from 'next/app'
import { Web3ReactProvider } from '@web3-react/core'
import { Web3Provider } from '@ethersproject/providers'
import { Layout } from 'components/layout'

function getLibrary(provider: any): Web3Provider {
  const library = new Web3Provider(provider)
  return library
}

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <Web3ReactProvider getLibrary={getLibrary}>
      <ChakraProvider>
        <Layout>
          <Component {...pageProps} />
        </Layout>
      </ChakraProvider>
    </Web3ReactProvider>
  )
}

export default MyApp