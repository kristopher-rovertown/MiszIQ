package com.example.misziq.ui.screens

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Psychology
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.misziq.ui.theme.RoyalBlue
import com.example.misziq.ui.theme.Turquoise
import kotlinx.coroutines.delay

@Composable
fun SplashScreen(
    onSplashComplete: () -> Unit
) {
    var startAnimation by remember { mutableStateOf(false) }

    // Logo animations
    val logoScale by animateFloatAsState(
        targetValue = if (startAnimation) 1f else 0.5f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessLow
        ),
        label = "logoScale"
    )

    val logoAlpha by animateFloatAsState(
        targetValue = if (startAnimation) 1f else 0f,
        animationSpec = tween(durationMillis = 500),
        label = "logoAlpha"
    )

    // Title animations
    val titleOffset by animateDpAsState(
        targetValue = if (startAnimation) 0.dp else 50.dp,
        animationSpec = tween(durationMillis = 600, delayMillis = 300),
        label = "titleOffset"
    )

    val titleAlpha by animateFloatAsState(
        targetValue = if (startAnimation) 1f else 0f,
        animationSpec = tween(durationMillis = 600, delayMillis = 300),
        label = "titleAlpha"
    )

    // Subtitle alpha
    val subtitleAlpha by animateFloatAsState(
        targetValue = if (startAnimation) 1f else 0f,
        animationSpec = tween(durationMillis = 400, delayMillis = 600),
        label = "subtitleAlpha"
    )

    // Pulse animation for rings
    val infiniteTransition = rememberInfiniteTransition(label = "pulse")
    val pulseScale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 1.5f,
        animationSpec = infiniteRepeatable(
            animation = tween(1500, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "pulseScale"
    )

    // Loading dots animation
    val dotsTransition = rememberInfiniteTransition(label = "dots")
    val dot1Scale by dotsTransition.animateFloat(
        initialValue = 0.5f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(600),
            repeatMode = RepeatMode.Reverse
        ),
        label = "dot1"
    )
    val dot2Scale by dotsTransition.animateFloat(
        initialValue = 0.5f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(600, delayMillis = 200),
            repeatMode = RepeatMode.Reverse
        ),
        label = "dot2"
    )
    val dot3Scale by dotsTransition.animateFloat(
        initialValue = 0.5f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(600, delayMillis = 400),
            repeatMode = RepeatMode.Reverse
        ),
        label = "dot3"
    )

    LaunchedEffect(Unit) {
        startAnimation = true
        delay(2500)
        onSplashComplete()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.linearGradient(
                    colors = listOf(
                        RoyalBlue.copy(alpha = 0.9f),
                        RoyalBlue,
                        Color(0xFF334499)
                    )
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        // Floating orbs in background
        FloatingOrbs(startAnimation = startAnimation)

        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier.fillMaxSize()
        ) {
            Spacer(modifier = Modifier.weight(1f))

            // Animated logo with pulse rings
            Box(
                contentAlignment = Alignment.Center
            ) {
                // Pulse rings
                for (i in 0..2) {
                    Box(
                        modifier = Modifier
                            .size((140 + i * 30).dp)
                            .scale(pulseScale)
                            .alpha((2 - pulseScale).coerceIn(0f, 1f) * 0.3f)
                            .background(
                                color = Color.White.copy(alpha = 0.2f),
                                shape = CircleShape
                            )
                    )
                }

                // Main logo container
                Box(
                    modifier = Modifier
                        .size(120.dp)
                        .scale(logoScale)
                        .alpha(logoAlpha)
                        .background(
                            color = Color.White,
                            shape = CircleShape
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Psychology,
                        contentDescription = "Brain",
                        modifier = Modifier.size(60.dp),
                        tint = RoyalBlue
                    )
                }
            }

            Spacer(modifier = Modifier.height(30.dp))

            // App title
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier
                    .offset(y = titleOffset)
                    .alpha(titleAlpha)
            ) {
                Text(
                    text = "MiszIQ",
                    fontSize = 48.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White,
                    letterSpacing = 2.sp
                )

                Spacer(modifier = Modifier.height(8.dp))

                Text(
                    text = "TRAIN YOUR BRAIN",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Medium,
                    color = Color.White.copy(alpha = 0.9f),
                    letterSpacing = 4.sp
                )
            }

            Spacer(modifier = Modifier.weight(1f))

            // Loading dots
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier
                    .alpha(subtitleAlpha)
                    .padding(bottom = 60.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(10.dp)
                        .scale(dot1Scale)
                        .alpha(dot1Scale)
                        .background(Color.White, CircleShape)
                )
                Box(
                    modifier = Modifier
                        .size(10.dp)
                        .scale(dot2Scale)
                        .alpha(dot2Scale)
                        .background(Color.White, CircleShape)
                )
                Box(
                    modifier = Modifier
                        .size(10.dp)
                        .scale(dot3Scale)
                        .alpha(dot3Scale)
                        .background(Color.White, CircleShape)
                )
            }
        }
    }
}

@Composable
private fun FloatingOrbs(startAnimation: Boolean) {
    val orbData = listOf(
        Triple(0.15f, 0.2f, 80.dp),
        Triple(0.85f, 0.15f, 60.dp),
        Triple(0.1f, 0.7f, 100.dp),
        Triple(0.9f, 0.6f, 50.dp),
        Triple(0.3f, 0.85f, 70.dp),
        Triple(0.75f, 0.8f, 90.dp)
    )

    BoxWithConstraints(modifier = Modifier.fillMaxSize()) {
        orbData.forEachIndexed { index, (xFraction, yFraction, size) ->
            val orbScale by animateFloatAsState(
                targetValue = if (startAnimation) 1f else 0.3f,
                animationSpec = tween(
                    durationMillis = 1000,
                    delayMillis = index * 100
                ),
                label = "orb$index"
            )

            val orbAlpha by animateFloatAsState(
                targetValue = if (startAnimation) 1f else 0f,
                animationSpec = tween(
                    durationMillis = 500,
                    delayMillis = index * 100
                ),
                label = "orbAlpha$index"
            )

            Box(
                modifier = Modifier
                    .offset(
                        x = maxWidth * xFraction - size / 2,
                        y = maxHeight * yFraction - size / 2
                    )
                    .size(size)
                    .scale(orbScale)
                    .alpha(orbAlpha)
                    .background(
                        Brush.radialGradient(
                            colors = listOf(
                                Turquoise.copy(alpha = 0.4f),
                                Turquoise.copy(alpha = 0.1f),
                                Color.Transparent
                            )
                        ),
                        shape = CircleShape
                    )
            )
        }
    }
}
