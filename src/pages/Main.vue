<template>
    <div class="container">
        <div v-if="errorMessage" class="error-message">
            <p>{{ errorMessage }}</p>
            <button @click="dismissError" class="dismiss">Dismiss</button>
        </div>
        <!-- ERC20 Token Form -->
        <div class="form">
            <h2>Create ERC20 Token</h2>
            <form @submit.prevent="create20">
                <input type="text" v-model="erc20.name" placeholder="Token Name">
                <input type="text" v-model="erc20.symbol" placeholder="Token Symbol">
                <input type="number" v-model="erc20.initialSupply" placeholder="Initial Supply">
                <a :href="`https://sepolia.etherscan.io/tx/${txHash}`">
                    <p>{{ txHash }}</p>
                </a>
                <button type="submit">Create ERC20 Token</button>
            </form>
        </div>

        <!-- ERC721 Token Form -->
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
            txHash: "",
            errorMessage: ""  // To store error messages
        };
    },
    methods: {
        ...mapActions({
            create20action: "createERC20Token",
            create721action: "createERC721Token"
        }),
        async create20() {
        if (!this.erc20.name || !this.erc20.symbol || !this.erc20.initialSupply) {
            this.errorMessage = "All fields must be filled.";
            return;
        }
        if (!this.isConnected()) {
            this.errorMessage = "No wallet connected.";
            return;
        }
        try {
            this.txHash = await this.create20action([this.erc20.name, this.erc20.symbol, this.erc20.initialSupply]);
            this.errorMessage = "";
        } catch (error) {
            this.errorMessage = error.message;  // Display the error message if transaction is declined
        }
    },
    async create721() {
        if (!this.erc721.name || !this.erc721.symbol) {
            this.errorMessage = "All fields must be filled.";
            return;
        }
        if (!this.isConnected()) {
            this.errorMessage = "No wallet connected.";
            return;
        }
        try {
            this.txHash = await this.create721action([this.erc721.name, this.erc721.symbol]);
            this.errorMessage = "";
        } catch (error) {
            this.errorMessage = error.message;  // Display the error message if transaction is declined
        }
    },
        isConnected() {
        return this.$store.state.isConnected;
    },
        dismissError() {
            this.errorMessage = ""; // Clear the error message
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

.error-message {
    padding: 10px; /* Reduced padding */
    margin-top: 20px;
    border-radius: 4px; /* Smoothed corners */
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    text-align: center;
    position: fixed; /* Keeps it on top of other content */
    top: 50px; /* Increased top margin to avoid navbar */
    left: 50%; /* Center horizontally */
    transform: translateX(-50%); /* Correct horizontal positioning */
    width: 50%; /* Narrower width */
    z-index: 1000; /* Ensures it stays on top of other elements */
    border: 1px solid #ff0000; /* Adds a red border */
}

</style>
