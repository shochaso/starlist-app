import { useState } from "react"
import { supabase } from "./supabase"

export default function Auth() {
  const [loading, setLoading] = useState(false)
  const [email, setEmail] = useState("")

  const handleLogin = async (e) => {
    e.preventDefault()
    
    try {
      setLoading(true)
      const { error } = await supabase.auth.signInWithOtp({ email })
      
      if (error) throw error
      alert("ログインリンクをメールで確認してください！")
    } catch (error) {
      alert(error.error_description || error.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="auth-container" style={{ maxWidth: "400px", margin: "0 auto", padding: "20px" }}>
      <h1>スターリスト</h1>
      <p>メールでログインリンクを受け取ります</p>
      <form onSubmit={handleLogin}>
        <div style={{ marginBottom: "10px" }}>
          <input
            type="email"
            placeholder="メールアドレス"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            style={{ width: "100%", padding: "8px" }}
          />
        </div>
        <button 
          disabled={loading}
          style={{ 
            backgroundColor: "#3ECF8E", 
            color: "white", 
            padding: "8px 12px",
            border: "none",
            borderRadius: "4px",
            cursor: "pointer"
          }}
        >
          {loading ? "メール送信中..." : "メールでログイン"}
        </button>
      </form>
    </div>
  )
}
