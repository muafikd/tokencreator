<template>
    <div class="container">
        <div class="form">
            <h2>Create ERC20 Token</h2>
            <form @submit.prevent="create20">
                <input type="text" v-model="erc20.name" placeholder="Token Name" required>
                <input type="text" v-model="erc20.symbol" placeholder="Token Symbol" required>
                <input type="number" v-model="erc20.initialSupply" placeholder="Initial Supply" required>
                <a :href="`https://sepolia.etherscan.io/tx/${txHash}`">
                    <p>{{ txHash }}</p>
                </a>
                <button type="submit">Create ERC20 Token</button>
            </form>
        </div>

        <div class="form">
            <h2>Create ERC721 Token</h2>
            <form @submit.prevent="create721">
                <input type="text" v-model="erc721.name" placeholder="Token Name" required>
                <input type="text" v-model="erc721.symbol" placeholder="Token Symbol" required>
                <a :href="`https://sepolia.etherscan.io/tx/${txHash}`">
                    <p>{{ txHash }}</p>
                </a>

                <button type="submit">Create ERC721 Token</button>
            </form>
        </div>
    </div>
</template>


<script>
import { mapActions } from 'vuex'
export default {
    name: 'MainPage',
    data() {
        return {
            erc20: {
                name: '',
                symbol: '',
                initialSupply: 0
            },
            erc721: {
                name: '',
                symbol: ''
            },
            txHash: ""
        };
    },
    methods: {
        ...mapActions({
            create20action: "createERC20Token",
            create721action: "createERC721Token"
        }),
        async create20() {
            this.txHash = await this.create20action([this.erc20.name, this.erc20.symbol, this.erc20.initialSupply])
        },
        async create721() {
            this.txHash = await this.create721action([this.erc20.name, this.erc20.symbol])
        }
    },
};
</script>

<style scoped>
.container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100vh;
    /* Full viewport height */
    background-color: #f4f4f4;
    /* Light grey background */
}

.form {
    background: white;
    padding: 20px;
    margin: 10px 0;
    border-radius: 8px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    width: 300px;
}

h2 {
    color: #333;
    text-align: center;
}

input[type="text"],
input[type="number"] {
    width: 100%;
    padding: 10px;
    margin: 8px 0;
    box-sizing: border-box;
    border: 2px solid #ccc;
    border-radius: 4px;
}

button {
    width: 100%;
    padding: 10px;
    background-color: #008CBA;
    /* Button Color */
    color: white;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    font-size: 16px;
    transition: background-color 0.3s;
}

button:hover {
    background-color: #005f73;
    /* Darker shade for hover */
}
</style>
