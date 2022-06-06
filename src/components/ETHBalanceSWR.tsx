import { useState, useEffect } from 'react'
import { useWeb3React } from '@web3-react/core'
import { Web3Provider } from '@ethersproject/providers'
import { Text } from '@chakra-ui/react'
import { formatEther } from '@ethersproject/units'
import useSWR from 'swr'

const fetcher = (library: any) => (...args: any) => {
  const [method, ...params] = args
  return library[method](...params)
}

const ETHBalanceSWR = () => {
  const { account, active, library, chainId } = useWeb3React<Web3Provider>()

  const { data: balance, mutate } = useSWR(['getBalance', account, 'latest'], {
    fetcher: fetcher(library),
  })

  useEffect(() => {
    if (!library) return

    console.log(`listening for blocks...`)
    library.on('block', () => {
      console.log(`update balance...`)
      mutate(undefined, true)
    })

    return () => {
      library.removeAllListeners('block')
    }
  }, [library])

  return (
    <div>
      {active && balance ? (
        <Text fontSize='md' w='100%' my='2' align='left'>
          ETH in account: {parseFloat(formatEther(balance)).toFixed(3)} {chainId === 31337 ? 'Test' : ' '} ETH
        </Text>
      ) : (
        <Text fontSize='md' w='100%' my='2' align='left'>
          ETH in account:
        </Text>
      )}
    </div>
  )
}

export default ETHBalanceSWR